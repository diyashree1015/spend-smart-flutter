import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  double _totalExpenses = 0.0;
  int _transactionCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final total = await _supabaseService.getTotalPersonalExpenses();
      final expenses = await _supabaseService.getPersonalExpenses();
      
      if (mounted) {
        setState(() {
          _totalExpenses = total;
          _transactionCount = expenses.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.userMetadata?['display_name'] ?? 
                       user?.email?.split('@')[0] ?? 
                       'User';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: const Text('Total Expenses'),
                          trailing: Text(
                            '₹${NumberFormat('#,##,###.##').format(_totalExpenses)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: const Text('Total Transactions'),
                          trailing: Text(
                            _transactionCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Member Since'),
                          trailing: Text(
                            DateFormat('MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Help & Support'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('About'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'SpendSmart',
                              applicationVersion: '1.0.0',
                              applicationIcon: const Icon(
                                Icons.account_balance_wallet,
                                size: 48,
                              ),
                              children: [
                                const Text(
                                  'A modern expense tracking application with analytics and insights.',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
