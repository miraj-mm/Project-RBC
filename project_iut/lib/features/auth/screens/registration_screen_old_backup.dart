import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../providers/auth_provider.dart';


class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingEmail = false;
  String? _emailExistsError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  // Check if email exists when user finishes typing
  Future<void> _checkEmailAvailability(String email) async {
    // Only check if email format is valid
    if (email.isEmpty || !email.toLowerCase().endsWith('@iut-dhaka.edu')) {
      if (mounted) {
        setState(() {
          _emailExistsError = null;
        });
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _isCheckingEmail = true;
        _emailExistsError = null;
      });
    }
    
    try {
      final exists = await ref.read(authStateProvider.notifier).checkEmailExists(email);
      
      if (mounted) {
        setState(() {
          _emailExistsError = exists 
              ? 'This email is already registered. Please login instead.' 
              : null;
          _isCheckingEmail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          _emailExistsError = null; // Don't block on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: const AppTopBar(title: AppStrings.registration),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  width: AppSizes.logoM,
                  height: AppSizes.logoM,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bloodtype,
                    color: AppColors.white,
                    size: AppSizes.iconXL,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        // Check email availability after user stops typing for 800ms
                        Future.delayed(const Duration(milliseconds: 800), () {
                          if (_emailController.text == value) {
                            _checkEmailAvailability(value);
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your IUT email',
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: _isCheckingEmail
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : _emailExistsError != null
                                ? const Icon(
                                    Icons.error,
                                    color: AppColors.error,
                                  )
                                : _emailController.text.isNotEmpty &&
                                        _emailController.text
                                            .toLowerCase()
                                            .endsWith('@iut-dhaka.edu')
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                      )
                                    : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.toLowerCase().endsWith('@iut-dhaka.edu')) {
                          return 'Please use your IUT email (@iut-dhaka.edu)';
                        }
                        if (!RegExp(r'^[\w-\.]+@iut-dhaka\.edu$').hasMatch(value.toLowerCase())) {
                          return 'Please enter a valid email';
                        }
                        // Check for email existence error
                        if (_emailExistsError != null) {
                          return _emailExistsError;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingXL),
                    
                    // Get OTP Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleGetOTP,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text(
                              AppStrings.getOtp,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingXL),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyMember,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            AppStrings.loginNow,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGetOTP() async {
    // Validate form first
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      
      // Check if email already exists before sending OTP
      debugPrint('🔍 Final check: Verifying email availability: $email');
      final exists = await ref.read(authStateProvider.notifier).checkEmailExists(email);
      
      if (!mounted) return;
      
      if (exists) {
        debugPrint('❌ Email already registered: $email');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already registered. Please login instead.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // Send OTP if email is new
      debugPrint('✅ Email available, sending OTP to: $email');
      await ref.read(authStateProvider.notifier).signInWithPhone(phone: email);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your email!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      
      context.push(AppRoutes.otpVerification, extra: email);
    } catch (e) {
      debugPrint('❌ Error in _handleGetOTP: $e');
      
      if (!mounted) return;
      
      // Parse error message to provide better feedback
      String errorMessage = 'Failed to send OTP';
      if (e.toString().contains('already registered')) {
        errorMessage = 'Email already registered. Please login instead.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Failed to send OTP: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

