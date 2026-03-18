import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../providers/auth_provider.dart';

/// New Registration Screen with Email Verification First
/// Flow: Enter Email → Verify Button → Show Status → Send OTP or Login
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isCheckingEmail = false;
  bool _emailChecked = false;
  bool? _emailExists; // null = not checked, true = exists, false = available
  
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
      appBar: const AppTopBar(title: AppStrings.registration),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.paddingXL),
              
              // Title
              Text(
                'Register Your Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingS),
              
              // Subtitle
              Text(
                'First, let\'s verify your IUT email',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Email Input Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_emailChecked,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your IUT email',
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: _emailChecked
                            ? Icon(
                                _emailExists! ? Icons.error : Icons.check_circle,
                                color: _emailExists! ? AppColors.error : AppColors.success,
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
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Show different content based on email check status
              if (!_emailChecked) ...[
                // Verify Email Button
                ElevatedButton(
                  onPressed: _isCheckingEmail ? null : _handleVerifyEmail,
                  child: _isCheckingEmail
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
                          'Verify Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ] else if (_emailExists == true) ...[
                // Email Already Registered
                _buildEmailExistsCard(isDarkMode),
              ] else ...[
                // Email Available
                _buildEmailAvailableCard(isDarkMode),
              ],
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.alreadyMember,
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
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
      ),
    );
  }

  // Build card for email already registered
  Widget _buildEmailExistsCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'Email Already Registered',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'This email is already associated with an account.',
            style: TextStyle(
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleReset,
                  child: const Text('Try Another Email'),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.login);
                  },
                  child: const Text('Go to Login'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build card for email available
  Widget _buildEmailAvailableCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 48,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'Email Available!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'This email is not registered. You can proceed with registration.',
            style: TextStyle(
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleReset,
                  child: const Text('Change Email'),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSendOTP,
                  child: const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Handle email verification
  Future<void> _handleVerifyEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isCheckingEmail = true;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();
      
      debugPrint('🔍 Verifying email: $email');
      
      // Check if email exists in users table
      final exists = await ref.read(authStateProvider.notifier).checkEmailExists(email);
      
      if (mounted) {
        setState(() {
          _emailChecked = true;
          _emailExists = exists;
          _isCheckingEmail = false;
        });
        
        debugPrint(exists ? '❌ Email already registered' : '✅ Email available');
      }
    } catch (e) {
      debugPrint('❌ Error verifying email: $e');
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying email: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Handle send OTP
  Future<void> _handleSendOTP() async {
    try {
      final email = _emailController.text.trim().toLowerCase();
      
      debugPrint('📧 Sending OTP to: $email');
      
      await ref.read(authStateProvider.notifier).signInWithPhone(phone: email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your email!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to OTP verification
        context.push(AppRoutes.otpVerification, extra: email);
      }
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      if (mounted) {
        String errorMessage = 'Failed to send OTP';
        final errorStr = e.toString().toLowerCase();
        
        if (errorStr.contains('already registered')) {
          errorMessage = 'Email already registered. Please login instead.';
        } else if (errorStr.contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Handle reset to try another email
  void _handleReset() {
    setState(() {
      _emailChecked = false;
      _emailExists = null;
      _emailController.clear();
    });
  }
}
