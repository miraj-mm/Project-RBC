import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';


class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  
  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
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
              
              const SizedBox(height: AppSizes.paddingXXL),
              
              // OTP Input
              Form(
                key: _formKey,
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
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
                    if (value.length != 4) {
                      return 'Please enter 4 digit OTP';
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
                onPressed: (_isLoading || _otpCode.length != 4) ? null : _handleVerifyOTP,
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
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement OTP verification logic
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        
        if (mounted) {
          Navigator.of(context).pushNamed('/sign-up');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP verification failed: ${e.toString()}'),
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

  void _handleResendOTP() async {
    try {
      // TODO: Implement resend OTP logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
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
