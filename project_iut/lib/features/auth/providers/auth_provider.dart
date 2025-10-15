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

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = const AsyncValue.error('Login failed', StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = const AsyncValue.error('Sign up failed', StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> signInWithPhone({required String phone}) async {
    try {
      state = const AsyncValue.loading();
      
      await SupabaseService.signInWithOtp(phone: phone);
      
      // OTP sent successfully, but user is not signed in yet
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await SupabaseService.verifyOtp(
        phone: phone,
        token: token,
      );

      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = const AsyncValue.error('OTP verification failed', StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
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