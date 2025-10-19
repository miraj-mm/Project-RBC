import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_router.dart';
import '../../../core/core.dart';
import '../providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                _emailSent ? l10n.checkYourEmail : l10n.forgotPasswordTitle,
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
                    ? l10n.passwordResetEmailSent
                    : l10n.enterIutEmailForReset,
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
                          labelText: l10n.email,
                          hintText: l10n.enterIutEmail,
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
                            return l10n.pleaseEnterEmail;
                          }
                          if (!value.toLowerCase().endsWith('@iut-dhaka.edu')) {
                            return l10n.pleaseUseIutEmail;
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
                          : Text(
                              l10n.sendResetLink,
                              style: const TextStyle(
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
                  child: Text(
                    l10n.backToLogin,
                    style: const TextStyle(
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
                      : Text(
                          l10n.resendEmail,
                          style: const TextStyle(
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
                      l10n.rememberPassword,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        l10n.login,
                        style: const TextStyle(
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
  }  void _handleSendResetLink() async {
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
