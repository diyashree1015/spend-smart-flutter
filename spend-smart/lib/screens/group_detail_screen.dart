import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/group.dart';
import '../models/expense.dart';
import '../models/group_member.dart';
import '../services/group_service.dart';
import '../utils/category_icons.dart';
import 'group_add_expense_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  List<Expense> _expenses = [];
  List<GroupMember> _members = [];
  Map<String, double> _balances = {};
  bool _isLoading = true;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final expenses = await _groupService.getGroupExpenses(widget.group.id);
      final members = await _groupService.getGroupMembers(widget.group.id);
      final balances = await _groupService.calculateBalances(widget.group.id);

      final total = expenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );

      if (mounted) {
        setState(() {
          _expenses = expenses;
          _members = members;
          _balances = balances;
          _totalExpense = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getBalanceText(String userId) {
    final balance = _balances[userId] ?? 0;
    if (balance > 0) {
      return 'Gets back ₹${balance.toStringAsFixed(2)}';
    } else if (balance < 0) {
      return 'Owes ₹${(-balance).toStringAsFixed(2)}';
    } else {
      return 'Settled up';
    }
  }

  Color _getBalanceColor(String userId) {
    final balance = _balances[userId] ?? 0;
    if (balance > 0) return Colors.green;
    if (balance < 0) return Colors.red;
    return Colors.grey;
  }

  Future<void> _showAddMemberDialog() async {
    final emailController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'friend@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the email of the person you want to add',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (emailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter an email'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        await _groupService.addMemberToGroup(
                          widget.group.id,
                          emailController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Member added successfully! 🎉'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          _loadData();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setDialogState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _groupService.currentUserId;
    final sharePerPerson = _members.isEmpty ? 0.0 : _totalExpense / _members.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    slivers: [
                      // Summary Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Text(
                                    'Total Group Expense',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${NumberFormat('#,##,###.##').format(_totalExpense)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            'Members',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _members.length.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Share per person',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '₹${sharePerPerson.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Your Balance
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: _getBalanceColor(currentUserId),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Your Balance',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          _getBalanceText(currentUserId),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _getBalanceColor(currentUserId),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Members Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Members (${_members.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showAddMemberDialog,
                                icon: const Icon(Icons.person_add),
                                label: const Text('Add Member'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: _members.map((member) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      (member.displayName ?? member.email ?? 'U')
                                          .substring(0, 1)
                                          .toUpperCase(),
                                    ),
                                  ),
                                  title: Text(
                                    member.displayName ?? member.email ?? 'Unknown',
                                  ),
                                  trailing: Text(
                                    _getBalanceText(member.userId),
                                    style: TextStyle(
                                      color: _getBalanceColor(member.userId),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      // Expenses Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Expenses (${_expenses.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      _expenses.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No expenses yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final expense = _expenses[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 4.0,
                                    ),
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(12),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              CategoryIcons.getColor(
                                                      expense.category)
                                                  .withOpacity(0.2),
                                          child: Icon(
                                            CategoryIcons.getIcon(
                                                expense.category),
                                            color: CategoryIcons.getColor(
                                                expense.category),
                                          ),
                                        ),
                                        title: Text(
                                          expense.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Paid by ${expense.paidByName ?? 'Unknown'}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              DateFormat('MMM dd, yyyy')
                                                  .format(expense.date),
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          '₹${NumberFormat('#,##,###.##').format(expense.amount)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: _expenses.length,
                              ),
                            ),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupAddExpenseScreen(group: widget.group),
            ),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
