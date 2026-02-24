import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';

class GroupService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get current user ID
  String get currentUserId => _client.auth.currentUser!.id;

  // ========================================
  // 1️⃣ CREATE GROUP (FIXED)
  // ========================================
  Future<Group> createGroup(String name, String? description) async {
    try {
      print('📝 Creating group: $name');
      
      // Insert into groups table
      final response = await _client
          .from('groups')
          .insert({
            'name': name,
            'description': description,
            'created_by': currentUserId,
          })
          .select()
          .single();

      print('✅ Group created with ID: ${response['id']}');
      final group = Group.fromJson(response);

      // IMMEDIATELY add creator to group_members
      print('👤 Adding creator to group_members...');
      await _client.from('group_members').insert({
        'group_id': group.id,
        'user_id': currentUserId,
      });
      
      print('✅ Creator added to group_members');
      return group;
    } catch (e) {
      print('❌ Error creating group: $e');
      throw Exception('Failed to create group: $e');
    }
  }

  // ========================================
  // 2️⃣ GET USER GROUPS (FIXED - Filter by membership)
  // ========================================
  Future<List<Group>> getUserGroups() async {
    try {
      print('📋 Fetching groups for user: $currentUserId');
      
      // Get groups where user is a member
      final memberResponse = await _client
          .from('group_members')
          .select('group_id')
          .eq('user_id', currentUserId);

      final groupIds = (memberResponse as List)
          .map((m) => m['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        print('ℹ️ User is not a member of any groups');
        return [];
      }

      print('📊 User is member of ${groupIds.length} groups');

      // Fetch full group details
      final groupsResponse = await _client
          .from('groups')
          .select()
          .inFilter('id', groupIds)
          .order('created_at', ascending: false);

      final groups = (groupsResponse as List)
          .map((json) => Group.fromJson(json))
          .toList();

      print('✅ Fetched ${groups.length} groups');
      return groups;
    } catch (e) {
      print('❌ Error fetching groups: $e');
      throw Exception('Failed to fetch groups: $e');
    }
  }

  // ========================================
  // 3️⃣ GET GROUP MEMBERS (FIXED - Proper JOIN)
  // ========================================
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    try {
      print('👥 Fetching members for group: $groupId');
      
      final response = await _client
          .from('group_members')
          .select('user_id, profiles(email, display_name)')
          .eq('group_id', groupId);

      final members = (response as List).map((json) {
        final member = GroupMember(
          id: json['user_id'] as String, // Use user_id as id
          groupId: groupId,
          userId: json['user_id'] as String,
          joinedAt: DateTime.now(), // Default since not selected
        );

        // Extract profile data
        if (json['profiles'] != null) {
          member.displayName = json['profiles']['display_name'] as String?;
          member.email = json['profiles']['email'] as String?;
        }

        return member;
      }).toList();

      print('✅ Fetched ${members.length} members');
      return members;
    } catch (e) {
      print('❌ Error fetching members: $e');
      throw Exception('Failed to fetch group members: $e');
    }
  }

  // ========================================
  // 4️⃣ ADD MEMBER BY EMAIL (FIXED)
  // ========================================
  Future<void> addMemberToGroup(String groupId, String email) async {
    final client = Supabase.instance.client;

    final profile = await client
        .from('profiles')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (profile == null) {
      throw Exception("User not found. They must sign up first.");
    }

    await client.from('group_members').insert({
      'group_id': groupId,
      'user_id': profile['id'],
    });
  }

  // ========================================
  // 5️⃣ GET GROUP EXPENSES (FIXED)
  // ========================================
  Future<List<Expense>> getGroupExpenses(String groupId) async {
    try {
      print('💰 Fetching expenses for group: $groupId');
      
      final response = await _client
          .from('expenses')
          .select('*, profiles!expenses_paid_by_fkey(display_name)')
          .eq('group_id', groupId)
          .order('date', ascending: false);

      final expenses = (response as List).map((json) {
        final expense = Expense.fromJson(json);
        if (json['profiles'] != null) {
          expense.paidByName = json['profiles']['display_name'] as String?;
        }
        return expense;
      }).toList();

      print('✅ Fetched ${expenses.length} expenses');
      return expenses;
    } catch (e) {
      print('❌ Error fetching expenses: $e');
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  // ========================================
  // 6️⃣ ADD EXPENSE (FIXED - Proper validation)
  // ========================================
  Future<void> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String category,
    String? note,
  }) async {
    try {
      print('💸 Adding expense: $title (₹$amount) to group: $groupId');
      
      if (groupId.isEmpty) {
        throw Exception('Group ID cannot be empty');
      }

      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      final expenseData = {
        'group_id': groupId,
        'title': title,
        'amount': amount,
        'category': category,
        'paid_by': currentUserId,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'note': note,
      };

      print('📤 Inserting expense data: $expenseData');

      await _client.from('expenses').insert(expenseData);

      print('✅ Expense added successfully');
    } catch (e) {
      print('❌ Error adding expense: $e');
      throw Exception('Failed to add expense: $e');
    }
  }

  // ========================================
  // 7️⃣ CALCULATE BALANCES (FIXED - Proper split logic)
  // ========================================
  Future<Map<String, double>> calculateBalances(String groupId) async {
    final client = Supabase.instance.client;

    final members = await client
        .from('group_members')
        .select()
        .eq('group_id', groupId);

    final expenses = await client
        .from('expenses')
        .select()
        .eq('group_id', groupId);

    final total = expenses.fold<double>(
        0,
        (sum, e) => sum + (e['amount'] as num).toDouble());

    final memberCount = members.length;

    if (memberCount == 0) return {};

    final share = total / memberCount;

    Map<String, double> balances = {};

    for (var member in members) {
      final userId = member['user_id'];

      final paid = expenses
          .where((e) => e['paid_by'] == userId)
          .fold<double>(
              0,
              (sum, e) => sum + (e['amount'] as num).toDouble());

      balances[userId] = paid - share;
    }

    return balances;
  }

  // ========================================
  // 8️⃣ REAL-TIME STREAM (FIXED)
  // ========================================
  Stream<List<Expense>> streamGroupExpenses(String groupId) {
    print('📡 Starting real-time stream for group: $groupId');
    
    return _client
        .from('expenses')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('date', ascending: false)
        .map((data) {
          print('🔄 Real-time update: ${data.length} expenses');
          return data.map((json) => Expense.fromJson(json)).toList();
        });
  }

  // ========================================
  // 9️⃣ JOIN GROUP BY INVITE CODE
  // ========================================
  Future<Group> joinGroupByInviteCode(String inviteCode) async {
    try {
      print('🔗 Joining group with code: $inviteCode');
      
      // Find group
      final groupResponse = await _client
          .from('groups')
          .select()
          .eq('invite_code', inviteCode.toUpperCase())
          .maybeSingle();

      if (groupResponse == null) {
        print('❌ Invalid invite code');
        throw Exception('Invalid invite code');
      }

      final group = Group.fromJson(groupResponse);
      print('✅ Found group: ${group.name}');

      // Check if already member
      final existingMember = await _client
          .from('group_members')
          .select('id')
          .eq('group_id', group.id)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existingMember != null) {
        print('⚠️ Already a member');
        throw Exception('You are already a member of this group');
      }

      // Add to group
      await _client.from('group_members').insert({
        'group_id': group.id,
        'user_id': currentUserId,
      });

      print('✅ Joined group successfully');
      return group;
    } catch (e) {
      print('❌ Error joining group: $e');
      if (e.toString().contains('Invalid') || 
          e.toString().contains('already a member')) {
        rethrow;
      }
      throw Exception('Failed to join group: $e');
    }
  }

  // ========================================
  // 🔟 GET USER PROFILE
  // ========================================
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  // ========================================
  // DELETE EXPENSE (BONUS)
  // ========================================
  Future<void> deleteExpense(String expenseId) async {
    try {
      print('🗑️ Deleting expense: $expenseId');
      
      await _client
          .from('expenses')
          .delete()
          .eq('id', expenseId);

      print('✅ Expense deleted');
    } catch (e) {
      print('❌ Error deleting expense: $e');
      throw Exception('Failed to delete expense: $e');
    }
  }
}
