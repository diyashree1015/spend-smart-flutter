import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
import 'personal_expense_screen_v2.dart';
import 'group_list_screen.dart';
import 'profile_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PersonalExpenseScreenV2(),
    const GroupListScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Personal',
    ),
    NavigationDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: 'Groups',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_circle_outlined),
      selectedIcon: Icon(Icons.account_circle),
      label: 'Profile',
    ),
  ];

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Personal'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: Text('Groups'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.account_circle_outlined),
      selectedIcon: Icon(Icons.account_circle),
      label: Text('Profile'),
    ),
  ];

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use NavigationRail for wide screens (web/tablet)
        if (constraints.maxWidth >= 640) {
          return Scaffold(
            body: Row(
              children: [
                // Navigation Rail
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SpendSmart',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: _logout,
                          tooltip: 'Logout',
                        ),
                      ),
                    ),
                  ),
                  destinations: _railDestinations,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Main content
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          );
        } else {
          // Use BottomNavigationBar for narrow screens (mobile)
          return Scaffold(
            appBar: AppBar(
              title: const Text('SpendSmart'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: _screens[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _destinations,
            ),
          );
        }
      },
    );
  }
}
