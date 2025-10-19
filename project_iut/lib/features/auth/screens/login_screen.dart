import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_router.dart';
import '../../../core/core.dart';
import '../providers/auth_provider.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return PopScope(
      canPop: false, // Prevent accidental back navigation from login
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Show confirmation dialog before exiting
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.paddingXXL),
              
              // Logo and App Name
              Column(
                children: [
                  Container(
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
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingXXL),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Field (Phone login disabled in Supabase)
                    TextFormField(
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'IUT Email',
                        hintText: 'Enter your @iut-dhaka.edu email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your IUT email';
                        }
                        final v = value.trim();
                        if (!v.toLowerCase().endsWith('@iut-dhaka.edu')) {
                          return 'Please use your IUT email (@iut-dhaka.edu)';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        hintText: AppStrings.enterPassword,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Your Password';
                        }
                        if (value.length < 6) {
                          return 'Password Must Be at Least 6 Characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingS),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push(AppRoutes.forgotPassword);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: AppStrings.forgotPassword,
                            style: TextStyle(color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            children: const [
                              TextSpan(
                                text: ' ${AppStrings.clickHere}',
                                style: TextStyle(color: AppColors.primaryRed),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                              AppStrings.login,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // OR Divider
                    const SizedBox(height: AppSizes.paddingXL),
                    
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(AppRoutes.registration);
                          },
                          child: const Text(
                            AppStrings.signUp,
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
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Do you want to exit the application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // On web, we can't actually close the tab, but we can show a message
              // On mobile, this would exit the app
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('🔐 Attempting login with: ${_identifierController.text.trim()}');
        
        await ref.read(authStateProvider.notifier).signInWithEmailOrPhone(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
        
        print('✅ Login successful, navigating to main...');
        
        if (mounted) {
          // Use replace to prevent back navigation to login
          context.go(AppRoutes.main);
        }
      } catch (e) {
        print('❌ Login error: $e');
        if (mounted) {
          // Parse error message to show user-friendly message
          String errorMessage = 'Login failed';
          final errorStr = e.toString().toLowerCase();
          
          if (errorStr.contains('invalid login credentials') || 
              errorStr.contains('invalid password') ||
              errorStr.contains('wrong password')) {
            errorMessage = 'Incorrect email or password. Please try again.';
          } else if (errorStr.contains('email not confirmed')) {
            errorMessage = 'Please verify your email first.';
          } else if (errorStr.contains('user not found')) {
            errorMessage = 'No account found with this email.';
          } else if (errorStr.contains('network')) {
            errorMessage = 'Network error. Please check your connection.';
          } else {
            errorMessage = 'Login failed: ${e.toString()}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

