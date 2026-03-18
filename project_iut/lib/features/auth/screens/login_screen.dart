import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_router.dart';
import '../../../core/core.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';


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
    final l10n = AppLocalizations.of(context)!;
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
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.paddingXL), // Extra space for toggles
                  const SizedBox(height: AppSizes.paddingL),
                  
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
                        labelText: l10n.iutEmail,
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
                          return l10n.pleaseEnterIutEmail;
                        }
                        final v = value.trim();
                        if (!v.toLowerCase().endsWith('@iut-dhaka.edu')) {
                          return l10n.pleaseUseIutEmail;
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
                        labelText: l10n.password,
                        hintText: l10n.enterPassword,
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
                          return l10n.pleaseEnterYourPassword;
                        }
                        if (value.length < 6) {
                          return l10n.passwordMustBe6;
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
                            text: l10n.forgotPassword,
                            style: TextStyle(color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: ' ${l10n.clickHere}',
                                style: const TextStyle(color: AppColors.primaryRed),
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
                          : Text(
                              l10n.login,
                              style: const TextStyle(
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
                          l10n.dontHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(AppRoutes.registration);
                          },
                          child: Text(
                            l10n.signUp,
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
            ],
          ),
        ),
            
            // Compact toggles at top right
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language Toggle (EN/বাং)
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? AppColors.darkCard.withOpacity(0.8)
                          : AppColors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode 
                            ? AppColors.grey.withOpacity(0.3)
                            : AppColors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Toggle language between English and Bengali
                          ref.read(languageProvider.notifier).toggleLanguage();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.language,
                                size: 16,
                                color: isDarkMode 
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Consumer(
                                builder: (context, ref, _) {
                                  final languageState = ref.watch(languageProvider);
                                  final isEnglish = languageState.locale.languageCode == 'en';
                                  return Text(
                                    isEnglish ? 'EN' : 'বাং',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode 
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Dark Mode Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? AppColors.darkCard.withOpacity(0.8)
                          : AppColors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode 
                            ? AppColors.grey.withOpacity(0.3)
                            : AppColors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                size: 16,
                                color: isDarkMode 
                                    ? Colors.amber
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  void _showExitConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitApp),
        content: Text(l10n.exitAppMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // On web, we can't actually close the tab, but we can show a message
              // On mobile, this would exit the app
            },
            child: Text(
              l10n.exit,
              style: const TextStyle(color: AppColors.error),
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
          final l10n = AppLocalizations.of(context)!;
          // Parse error message to show user-friendly message
          String errorMessage = l10n.loginFailed;
          final errorStr = e.toString().toLowerCase();
          
          if (errorStr.contains('invalid login credentials') || 
              errorStr.contains('invalid password') ||
              errorStr.contains('wrong password')) {
            errorMessage = l10n.incorrectEmailOrPassword;
          } else if (errorStr.contains('email not confirmed')) {
            errorMessage = l10n.pleaseVerifyEmail;
          } else if (errorStr.contains('user not found')) {
            errorMessage = l10n.noAccountFound;
          } else if (errorStr.contains('network')) {
            errorMessage = l10n.networkError;
          } else {
            errorMessage = '${l10n.loginFailed}: ${e.toString()}';
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

