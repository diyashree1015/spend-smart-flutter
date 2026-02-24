import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/auth_wrapper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
 await Supabase.initialize(
  url: 'https://akdkaxvrhjqjweapadfh.supabase.co',
  anonKey: 'sb_publishable_slHgg1xlB_mywhNEwKFFFQ_HqsDY0Y4',
);
  
  runApp(const SpendSmartApp());
}

class SpendSmartApp extends StatelessWidget {
  const SpendSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AuthWrapper(),
    );
  }
}
