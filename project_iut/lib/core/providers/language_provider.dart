import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageState {
  final Locale locale;
  
  const LanguageState({required this.locale});
  
  LanguageState copyWith({Locale? locale}) {
    return LanguageState(
      locale: locale ?? this.locale,
    );
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(const LanguageState(locale: Locale('en'))) {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      state = LanguageState(locale: Locale(languageCode));
    } catch (e) {
      // If loading fails, keep default English
      state = const LanguageState(locale: Locale('en'));
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
      state = LanguageState(locale: Locale(languageCode));
    } catch (e) {
      // If saving fails, still update the UI
      state = LanguageState(locale: Locale(languageCode));
    }
  }
  
  Future<void> toggleLanguage() async {
    final newLanguageCode = state.locale.languageCode == 'en' ? 'bn' : 'en';
    await setLanguage(newLanguageCode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>(
  (ref) => LanguageNotifier(),
);
