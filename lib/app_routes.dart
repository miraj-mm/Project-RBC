import 'package:flutter/material.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/registration_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/home/screens/main_app_screen.dart';
import 'features/location/screens/location_input_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/registration': (context) => const RegistrationScreen(),
  '/otp-verification': (context) {
    final phoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
    return OtpVerificationScreen(phoneNumber: phoneNumber);
  },
  '/sign-up': (context) => const SignUpScreen(),
  '/location': (context) => const LocationInputScreen(),
  '/main': (context) => const MainAppScreen(),
};
