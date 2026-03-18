import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/core.dart';

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

// Auth status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    SupabaseService.instance.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.initialSession:
          state = AsyncValue.data(session?.user);
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          state = const AsyncValue.data(null);
          break;
        default:
          // Handle other events like passwordRecovery, userUpdated, etc.
          if (session?.user != null) {
            state = AsyncValue.data(session?.user);
          }
          break;
      }
    });

    // Set initial state
    final currentUser = SupabaseService.currentUser;
    state = AsyncValue.data(currentUser);
  }

  Future<void> signInWithEmailOrPhone({
    required String identifier,
    required String password,
  }) async {
    try {
      print('🔍 Attempting login with identifier: $identifier');
      state = const AsyncValue.loading();
      AuthResponse response;
      
      // Only support email login (phone auth is disabled)
      if (_isValidIUTEmail(identifier)) {
        print('📧 Logging in with email');
        response = await SupabaseService.signInWithEmail(
          email: identifier,
          password: password,
        );
      } else {
        print('❌ Only IUT email login is supported');
        throw Exception('Please login with your @iut-dhaka.edu email address. Phone login is not supported.');
      }
      
      if (response.user != null) {
        print('✅ Login successful! User: ${response.user!.email}');
        state = AsyncValue.data(response.user);
      } else {
        print('❌ Login failed: No user returned');
        state = const AsyncValue.error('Login failed', StackTrace.empty);
        throw Exception('Login failed - no user returned');
      }
    } catch (e) {
      print('❌ Login error in provider: $e');
      state = AsyncValue.error(e.toString(), StackTrace.current);
      rethrow;
    }
  }

  /// Check if email already exists in the database
  /// This checks ONLY the users table (completed registrations)
  Future<bool> checkEmailExists(String email) async {
    try {
      final emailLower = email.toLowerCase().trim();
      debugPrint('🔍 [DB Check] Checking users table for email: $emailLower');
      
      final result = await SupabaseService.from('users')
          .select('id')
          .eq('email', emailLower)
          .limit(1);
      
      final exists = result.isNotEmpty;
      debugPrint(exists 
          ? '❌ [DB Check] Email already exists in users table' 
          : '✅ [DB Check] Email available in users table');
      return exists;
    } catch (e) {
      debugPrint('❌ [DB Check] Error checking email: $e');
      // If error, assume email exists to prevent registration (fail-safe)
      return true;
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      print('📝 Starting signup for: $email');
      
      // Validate IUT email
      if (!_isValidIUTEmail(email)) {
        throw Exception('Only @iut-dhaka.edu email addresses are allowed');
      }

      state = const AsyncValue.loading();
      
      // Check if user already exists in database
      print('🔍 Checking if email already exists...');
      final existingUser = await SupabaseService.from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      
      if (existingUser != null) {
        print('❌ Email already registered!');
        throw Exception('This email is already registered. Please login instead.');
      }
      print('✅ Email is available');
      
      // Get current user (authenticated from OTP)
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found. Please verify OTP first.');
      }
      
      // Update the current user's password and metadata
      try {
        print('🔑 Updating user password...');
        await SupabaseService.updatePassword(newPassword: password);
        
        print('📋 Updating user metadata...');
        // Update user metadata in auth
        await SupabaseService.instance.auth.updateUser(
          UserAttributes(data: userData),
        );
        
        print('💾 Inserting user data into database...');
        // Insert user data into users table
        final now = DateTime.now();
        final userDbData = {
          'id': currentUser.id,
          'name': userData?['name'] ?? 'User',
          'email': email,
          'phone': userData?['phone'],
          'gender': userData?['gender'],
          'age': userData?['age'],
          'blood_group': userData?['blood_group'],
          'last_donation_date': userData?['last_donation_date'],
          'profile_picture_url': userData?['profile_picture_url'], // Profile picture support
          'lives_saved': 0,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
        
        await SupabaseService.from('users').insert(userDbData);
        print('✅ User data inserted into database!');
        
      } catch (e) {
        print('❌ Error during signup: $e');
        throw Exception('Failed to complete signup: $e');
      }
      
      // Sign out the user to force manual login
      print('🚪 Signing out user...');
      await SupabaseService.signOut();
      
      // Keep state as null so user is not auto-logged in
      state = const AsyncValue.data(null);
      print('✅ Signup complete, user signed out');
    } catch (e) {
      print('❌ Signup error: $e');
      state = AsyncValue.error(e.toString(), StackTrace.current);
      rethrow;
    }
  }

  Future<void> signInWithPhone({required String phone}) async {
    try {
      state = const AsyncValue.loading();
      
      final emailLower = phone.toLowerCase().trim();
      
      // STRICT CHECK: Count rows with this email in users table
      debugPrint('🔍 [STRICT CHECK] Checking users table for email: $emailLower');
      
      try {
        final response = await SupabaseService.from('users')
            .select('id, email')
            .eq('email', emailLower)
            .limit(1);
        
        debugPrint('📊 [STRICT CHECK] Query response: $response');
        
        if (response.isNotEmpty) {
          debugPrint('❌ [STRICT CHECK] Email found in users table!');
          debugPrint('   Existing user: ${response[0]}');
          state = const AsyncValue.data(null);
          throw Exception('This email is already registered. Please login instead.');
        }
        
        debugPrint('✅ [STRICT CHECK] Email not found in users table - email is available');
      } catch (e) {
        if (e.toString().contains('already registered')) {
          rethrow;
        }
        debugPrint('⚠️ [STRICT CHECK] Error querying database: $e');
        // If we can't query the database, fail safe - don't allow registration
        throw Exception('Unable to verify email. Please try again.');
      }
      
      // Send OTP - This will fail if email already exists in Supabase Auth
      debugPrint('📧 [OTP] Sending OTP to: $emailLower');
      try {
        await SupabaseService.signUpWithOtp(email: emailLower);
        debugPrint('✅ [OTP] OTP sent successfully');
      } catch (otpError) {
        debugPrint('❌ [OTP] Error sending OTP: $otpError');
        final errorMsg = otpError.toString().toLowerCase();
        
        // If Supabase rejects because user exists in auth system
        if (errorMsg.contains('user already registered') || 
            errorMsg.contains('already exists') ||
            errorMsg.contains('already registered') ||
            errorMsg.contains('user_already_exists') ||
            errorMsg.contains('email already')) {
          debugPrint('❌ [OTP] Email exists in Supabase Auth (incomplete registration detected)');
          throw Exception('This email is already registered. Please login instead.');
        }
        
        // Other OTP errors
        throw Exception('Failed to send OTP: ${otpError.toString()}');
      }
      
      // OTP sent successfully, but user is not signed in yet
      state = const AsyncValue.data(null);
      debugPrint('✅ [COMPLETE] OTP flow completed successfully');
    } catch (e) {
      debugPrint('❌ [ERROR] Error in signInWithPhone: $e');
      state = AsyncValue.error(e.toString(), StackTrace.current);
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await SupabaseService.verifyEmailOtp(
        email: phone,
        token: token,
      );

      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = const AsyncValue.error('OTP verification failed', StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      // Validate IUT email
      if (!_isValidIUTEmail(email)) {
        throw Exception('Only @iut-dhaka.edu email addresses are allowed');
      }

      await SupabaseService.resetPasswordForEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword({
    required String newPassword,
  }) async {
    try {
      await SupabaseService.updatePassword(newPassword: newPassword);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      rethrow;
    }
  }

  // Resend email confirmation
  Future<void> resendEmailConfirmation({
    required String email,
  }) async {
    try {
      await SupabaseService.resendEmailConfirmation(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Validate IUT email
  bool _isValidIUTEmail(String email) {
    return email.toLowerCase().endsWith('@iut-dhaka.edu');
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔓 AuthProvider: Starting sign out...');
      
      // Clear state first
      state = const AsyncValue.data(null);
      debugPrint('✅ AuthProvider: State cleared');
      
      // Sign out from Supabase
      await SupabaseService.signOut();
      debugPrint('✅ AuthProvider: Supabase sign out complete');
      
      // Ensure state is null
      state = const AsyncValue.data(null);
      debugPrint('✅ AuthProvider: Sign out successful');
    } catch (e) {
      debugPrint('❌ AuthProvider: Sign out error: $e');
      state = AsyncValue.error(e.toString(), StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await SupabaseService.instance.auth.updateUser(
        UserAttributes(data: metadata),
      );
      
      if (response.user != null) {
        state = AsyncValue.data(response.user);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}