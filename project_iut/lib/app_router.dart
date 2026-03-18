import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/registration_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/main_app_screen.dart';
import 'features/location/screens/location_input_screen.dart';
import 'features/blood_requests/screens/create_blood_request_screen.dart';
import 'features/blood_requests/screens/blood_requests_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/bus/screens/bus_route_info_screen.dart';
import 'core/services/supabase_service.dart';

/// Auth state notifier for router refresh
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    // Listen to Supabase auth state changes
    SupabaseService.instance.auth.onAuthStateChange.listen((data) {
      debugPrint('🔔 AuthStateNotifier: Auth state changed - ${data.event}');
      debugPrint('   User: ${data.session?.user.email ?? "null"}');
      notifyListeners();
    });
  }
}

/// Route names as constants for type safety
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String otpVerification = '/otp-verification';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  
  // Location
  static const String location = '/location';
  
  // Main app
  static const String main = '/main';
  
  // Blood requests
  static const String bloodRequests = '/blood-requests';
  static const String createBloodRequest = '/create-blood-request';
  
  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  
  // Bus
  static const String busRoute = '/bus-route';
}

/// GoRouter configuration
final _authStateNotifier = AuthStateNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  refreshListenable: _authStateNotifier, // Refresh router when auth state changes
  
  // Redirect logic for authentication
  redirect: (BuildContext context, GoRouterState state) async {
    final currentUser = SupabaseService.currentUser;
    final isAuthenticated = currentUser != null;
    final currentPath = state.matchedLocation;
    
    // Define route categories
    final isAuthRoute = currentPath == AppRoutes.login ||
        currentPath == AppRoutes.registration ||
        currentPath == AppRoutes.otpVerification ||
        currentPath == AppRoutes.forgotPassword;
    final isSignUpRoute = currentPath == AppRoutes.signUp;
    final isSplash = currentPath == AppRoutes.splash;
    final isPublicRoute = isSplash || isAuthRoute;

    debugPrint('🔀 Router redirect check:');
    debugPrint('   Path: $currentPath');
    debugPrint('   Authenticated: $isAuthenticated');

    // Allow splash screen always
    if (isSplash) {
      return null;
    }

    // Allow sign-up route and OTP verification for authenticated users (during profile completion)
    if (isSignUpRoute || currentPath == AppRoutes.otpVerification) {
      debugPrint('   ✅ On signup/OTP flow, allowing access');
      return null;
    }

    // If not authenticated and trying to access protected route, redirect to login
    if (!isAuthenticated && !isPublicRoute) {
      debugPrint('   ❌ Not authenticated, redirecting to login');
      return AppRoutes.login;
    }

    // If authenticated, check if user exists in users table (completed registration)
    if (isAuthenticated && isAuthRoute) {
      try {
        // Check if user has completed profile setup
        final userRecord = await SupabaseService.from('users')
            .select('id')
            .eq('id', currentUser.id)
            .maybeSingle();
        
        if (userRecord != null) {
          // User has completed registration, redirect to main
          debugPrint('   ✅ User profile complete, redirecting to main');
          return AppRoutes.main;
        } else {
          // User authenticated but profile not complete, allow auth routes
          debugPrint('   ⚠️ User authenticated but profile incomplete, staying on auth route');
          return null;
        }
      } catch (e) {
        debugPrint('   ❌ Error checking user profile: $e');
        return null;
      }
    }

    debugPrint('   ✅ No redirect needed');
    return null; // No redirect
  },

  routes: [
    // Splash Screen
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth Routes
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    GoRoute(
      path: AppRoutes.registration,
      name: 'registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    
    GoRoute(
      path: AppRoutes.otpVerification,
      name: 'otp-verification',
      builder: (context, state) {
        final email = state.extra as String?;
        return OtpVerificationScreen(email: email);
      },
    ),
    
    GoRoute(
      path: AppRoutes.signUp,
      name: 'sign-up',
      builder: (context, state) {
        final verifiedEmail = state.extra as String?;
        return SignUpScreen(verifiedEmail: verifiedEmail);
      },
    ),

    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Location
    GoRoute(
      path: AppRoutes.location,
      name: 'location',
      builder: (context, state) => const LocationInputScreen(),
    ),

    // Main App
    GoRoute(
      path: AppRoutes.main,
      name: 'main',
      builder: (context, state) => const MainAppScreen(),
    ),

    // Blood Requests
    GoRoute(
      path: AppRoutes.bloodRequests,
      name: 'blood-requests',
      builder: (context, state) => const BloodRequestsScreen(),
    ),
    
    GoRoute(
      path: AppRoutes.createBloodRequest,
      name: 'create-blood-request',
      builder: (context, state) => const CreateBloodRequestScreen(),
    ),

    // Profile
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // Bus Routes
    GoRoute(
      path: AppRoutes.busRoute,
      name: 'bus-route',
      builder: (context, state) => const BusRouteInfoScreen(),
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            '404 - Page Not Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'The route ${state.matchedLocation} does not exist.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.main),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);
