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
    required String phone,
  }) async {
    await instance.auth.signInWithOtp(
      phone: phone,
    );
  }

  static Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await instance.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
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