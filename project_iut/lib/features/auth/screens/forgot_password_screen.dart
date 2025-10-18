import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_router.dart';
import '../../../core/core.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.paddingXL),
              
              // Icon
              Icon(
                _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                size: 80,
                color: AppColors.primaryRed,
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Title
              Text(
                _emailSent ? 'Check Your Email' : 'Forgot Password?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              // Description
              Text(
                _emailSent
                    ? 'We have sent a password reset link to your email. Please check your inbox and follow the instructions.'
                    : 'Enter your IUT email address and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingXXL),
              
              if (!_emailSent) ...[
                // Email Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your IUT email',
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
                            return 'Please enter your email';
                          }
                          if (!value.toLowerCase().endsWith('@iut-dhaka.edu')) {
                            return 'Please use your IUT email (@iut-dhaka.edu)';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSizes.paddingXL),
                      
                      // Send Reset Link Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendResetLink,
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
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Email Sent Success Actions
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSizes.paddingM),
                
                TextButton(
                  onPressed: _isLoading ? null : _handleSendResetLink,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Resend Email',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                ),
              ],
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Remember Password? Login
              if (!_emailSent)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Login',
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
      ),
    );
  }

  void _handleSendResetLink() async {
    if (!_emailSent && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authStateProvider.notifier).sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _emailSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: ${e.toString()}'),
            backgroundColor: AppColors.error,
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
