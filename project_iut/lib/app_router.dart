import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/registration_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/home/screens/main_app_screen.dart';
import 'features/location/screens/location_input_screen.dart';
import 'features/blood_requests/screens/create_blood_request_screen.dart';
import 'features/blood_requests/screens/blood_requests_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/bus/screens/bus_route_info_screen.dart';
import 'core/services/supabase_service.dart';

/// Route names as constants for type safety
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String otpVerification = '/otp-verification';
  static const String signUp = '/sign-up';
  
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
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  
  // Redirect logic for authentication
  redirect: (BuildContext context, GoRouterState state) {
    final isAuthenticated = SupabaseService.currentUser != null;
    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.registration ||
        state.matchedLocation == AppRoutes.signUp ||
        state.matchedLocation == AppRoutes.otpVerification;
    final isSplash = state.matchedLocation == AppRoutes.splash;

    // Allow splash screen
    if (isSplash) {
      return null;
    }

    // If not authenticated and trying to access protected route, redirect to login
    if (!isAuthenticated && !isAuthRoute) {
      return AppRoutes.login;
    }

    // If authenticated and on auth route, redirect to main
    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.main;
    }

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
        final phoneNumber = state.extra as String?;
        return OtpVerificationScreen(phoneNumber: phoneNumber);
      },
    ),
    
    GoRoute(
      path: AppRoutes.signUp,
      name: 'sign-up',
      builder: (context, state) => const SignUpScreen(),
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
