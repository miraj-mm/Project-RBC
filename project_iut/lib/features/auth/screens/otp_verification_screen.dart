import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../providers/auth_provider.dart';


class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String? phoneNumber; // This will now contain email
  
  const OtpVerificationScreen({
    super.key,
    this.email,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String _otpCode = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: const AppTopBar(title: AppStrings.verifyOtp),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.paddingXL),
              
              // Instructions
              Text(
                AppStrings.enterVerificationCode,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              // Email display
              if (widget.email != null)
                Text(
                  'Sent to ${widget.email}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: AppSizes.paddingXXL),
              
              // OTP Input
              Form(
                key: _formKey,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    fieldHeight: 60,
                    fieldWidth: 60,
                    activeFillColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
                    inactiveFillColor: isDarkMode ? AppColors.darkBorder : AppColors.inputBorder,
                    selectedFillColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
                    activeColor: AppColors.primaryRed,
                    inactiveColor: AppColors.inputBorder,
                    selectedColor: AppColors.primaryRed,
                  ),
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  onCompleted: (value) {
                    setState(() {
                      _otpCode = value;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _otpCode = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter OTP';
                    }
                    if (value.length != 6) {
                      return 'Please enter 6 digit OTP';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingL),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.didntReceiveCode,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _handleResendOTP,
                    child: const Text(
                      AppStrings.resend,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Proceed Button
              ElevatedButton(
                onPressed: (_isLoading || _otpCode.length != 6) ? null : _handleVerifyOTP,
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
                        AppStrings.proceed,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
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

  void _handleVerifyOTP() async {
    // Ensure email is available before attempting verification
    if (widget.email == null || widget.email!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not available. Please restart the sign-in process.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('🔐 Verifying OTP for: ${widget.phoneNumber}');
        
        // Verify OTP with email - this will authenticate the user temporarily
        await ref.read(authStateProvider.notifier).verifyOtp(
          phone: widget.phoneNumber ?? '', // This is actually the email
          token: _otpCode,
        );
        
        print('✅ OTP verified! User authenticated temporarily for signup');
        
        if (mounted) {
          print('📝 Navigating to sign-up page...');
          // Use pushReplacement to prevent back navigation to OTP screen
          context.pushReplacement(AppRoutes.signUp, extra: widget.phoneNumber);
        }
      } catch (e) {
        print('❌ OTP verification failed: $e');
        if (mounted) {
          String errorMessage = 'OTP verification failed';
          final errorStr = e.toString().toLowerCase();
          
          if (errorStr.contains('invalid') || errorStr.contains('expired')) {
            errorMessage = 'Invalid or expired OTP. Please try again.';
          } else if (errorStr.contains('token')) {
            errorMessage = 'Invalid OTP code. Please check and try again.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
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

  void _handleResendOTP() async {
    try {
      // Resend OTP to email
      await ref.read(authStateProvider.notifier).signInWithPhone(
        phone: widget.phoneNumber ?? '', // This is actually the email
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully to your email'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

