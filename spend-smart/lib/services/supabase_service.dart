import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/personal_expense.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ==========================
  // PERSONAL EXPENSES
  // ==========================

  Future<List<PersonalExpense>> getPersonalExpenses() async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('personal_expenses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => PersonalExpense.fromMap(e))
        .toList();
  }

  Future<void> addPersonalExpense(
    String title,
    double amount,
    String? category,
  ) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('personal_expenses').insert({
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
    });
  }

  Future<void> deletePersonalExpense(String id) async {
    await _client
        .from('personal_expenses')
        .delete()
        .eq('id', id);
  }

  Future<double> getTotalPersonalExpenses() async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('personal_expenses')
        .select('amount')
        .eq('user_id', userId);

    if (response.isEmpty) return 0.0;

    return (response as List).fold<double>(
      0.0,
      (sum, e) => sum + (e['amount'] as num).toDouble(),
    );
  }
}