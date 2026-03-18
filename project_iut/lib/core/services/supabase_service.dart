import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static SupabaseClient? _instance;
  
  static SupabaseClient get instance {
    if (_instance == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize() async {
    if (!AppConfig.isConfigValid) {
      throw Exception('Supabase configuration is invalid. Please check your .env file.');
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: AppConfig.debugMode,
    );

    _instance = Supabase.instance.client;
  }

  // Auth helpers
  static User? get currentUser => _instance?.auth.currentUser;
  static Session? get currentSession => _instance?.auth.currentSession;
  static bool get isAuthenticated => currentUser != null;

  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await instance.auth.signUp(
      email: email,
      password: password,
      data: data,
      emailRedirectTo: null, // Email confirmation will be sent
    );
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await instance.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    return await instance.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
  }

  static Future<void> signOut() async {
    try {
      debugPrint('🔓 SupabaseService: Signing out...');
      await instance.auth.signOut();
      debugPrint('✅ SupabaseService: Sign out complete');
    } catch (e) {
      debugPrint('❌ SupabaseService: Sign out error: $e');
      // Even if sign out fails, we should clear local state
      rethrow;
    }
  }

  // Email OTP for signup/verification
  static Future<void> signUpWithOtp({
    required String email,
  }) async {
    try {
      debugPrint('📧 [Supabase] Sending OTP to: $email');
      await instance.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null,
        shouldCreateUser: false, // DON'T create user - only send to new emails
      );
      debugPrint('✅ [Supabase] OTP sent successfully');
    } catch (e) {
      debugPrint('❌ [Supabase] OTP Error: $e');
      print('Supabase OTP Error: $e');
      rethrow;
    }
  }

  // Verify email OTP
  static Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    return await instance.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  // Send password reset email
  static Future<void> resetPasswordForEmail({
    required String email,
  }) async {
    await instance.auth.resetPasswordForEmail(
      email,
      redirectTo: null, // Can be set to deep link for password reset
    );
  }

  // Update user password
  static Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    return await instance.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Resend email confirmation
  static Future<void> resendEmailConfirmation({
    required String email,
  }) async {
    await instance.auth.resend(
      type: OtpType.email,
      email: email,
    );
  }

  // Database helpers
  static SupabaseQueryBuilder from(String table) {
    return instance.from(table);
  }

  // Storage helpers
  static SupabaseStorageClient get storage => instance.storage;

  // Realtime helpers
  static RealtimeChannel channel(String channelName) {
    return instance.channel(channelName);
  }
}