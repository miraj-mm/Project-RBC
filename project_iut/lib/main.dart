import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_iut/l10n/app_localizations.dart';
import 'core/core.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize app configuration
    await AppConfig.initialize();
    
    // Initialize Supabase
    await SupabaseService.initialize();
    
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
    final languageState = ref.watch(languageProvider);
    
    return MaterialApp.router(
      routerConfig: appRouter,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: languageState.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('bn'), // Bengali
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
