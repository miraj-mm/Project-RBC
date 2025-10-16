import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/core.dart';
import 'core/providers/theme_provider.dart';
import 'app_routes.dart';

// Replace these with your Supabase URL and anon key
const String SUPABASE_URL = 'https://egemeiipwqxsebikavow.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVnZW1laWlwd3F4c2ViaWthdm93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxMDUxNTgsImV4cCI6MjA3NTY4MTE1OH0.TznGitJ1yv_nEHhNNIfttPeDBv9cUx7OCwVZpaXaYSY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize app configuration
    await AppConfig.initialize();
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
    
    runApp(const ProviderScope(child: DonorApp()));
  } catch (e) {
    // If initialization fails, show error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'App Initialization Failed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class DonorApp extends ConsumerWidget {
  const DonorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
