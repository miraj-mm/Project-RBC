import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Mode Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeState {
  final bool isDarkMode;
  
  ThemeState({required this.isDarkMode});
  
  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'isDarkMode';
  
  ThemeNotifier() : super(ThemeState(isDarkMode: false)) {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_themeKey) ?? false;
      state = state.copyWith(isDarkMode: isDarkMode);
    } catch (e) {
      // Handle error - fallback to light mode
      state = state.copyWith(isDarkMode: false);
    }
  }
  
  Future<void> toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newDarkMode = !state.isDarkMode;
      await prefs.setBool(_themeKey, newDarkMode);
      state = state.copyWith(isDarkMode: newDarkMode);
    } catch (e) {
      // Handle error silently
    }
  }
  
  Future<void> setDarkMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDarkMode);
      state = state.copyWith(isDarkMode: isDarkMode);
    } catch (e) {
      // Handle error silently
    }
  }
}