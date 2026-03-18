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
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await instance.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await instance.auth.signOut();
  }

  static Future<void> signInWithOtp({
    String? phone,
    String? email,
  }) async {
    if (phone != null) {
      await instance.auth.signInWithOtp(
        phone: phone,
      );
    } else if (email != null) {
      await instance.auth.signInWithOtp(
        email: email,
      );
    } else {
      throw Exception('Either phone or email must be provided');
    }
  }

  static Future<AuthResponse> verifyOtp({
    String? phone,
    String? email,
    required String token,
  }) async {
    if (phone != null) {
      return await instance.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
    } else if (email != null) {
      return await instance.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
    } else {
      throw Exception('Either phone or email must be provided');
    }
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