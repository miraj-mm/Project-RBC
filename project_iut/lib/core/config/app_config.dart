import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'Project RBC';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  static bool get isConfigValid {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}