import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/hover_button.dart';
import '../../../core/providers/theme_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _bloodRequestNotifications = true;
  bool _donationReminders = true;
  bool _emergencyAlerts = true;
  bool _locationTracking = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'বাংলা (Bengali)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: 'App Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryColor(context),
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsItem(
              context,
              'Dark Mode',
              'Switch between light and dark theme',
              Icons.dark_mode,
              AppColors.textSecondary,
              trailing: Switch(
                value: ref.watch(themeProvider).isDarkMode,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                activeColor: AppColors.primaryRed,
              ),
            ),
            _buildSettingsItem(
              context,
              'Language',
              _selectedLanguage,
              Icons.language,
              AppColors.info,
              onTap: () => _showLanguageDialog(),
            ),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Notifications Section
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryColor(context),
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsItem(
              context,
              'Receive app notifications',
              'Get notified about important updates',
              Icons.notifications,
              AppColors.warning,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppColors.primaryRed,
              ),
            ),
            
            if (_notificationsEnabled) ...[
              _buildSettingsItem(
                context,
                'Get notified about urgent blood requests',
                'Receive alerts for emergency blood requests',
                Icons.bloodtype,
                AppColors.primaryRed,
                trailing: Switch(
                  value: _bloodRequestNotifications,
                  onChanged: (value) {
                    setState(() {
                      _bloodRequestNotifications = value;
                    });
                  },
                  activeColor: AppColors.primaryRed,
                ),
              ),
              _buildSettingsItem(
                context,
                'Remind me when I can donate again',
                'Get reminders for donation eligibility',
                Icons.schedule,
                AppColors.info,
                trailing: Switch(
                  value: _donationReminders,
                  onChanged: (value) {
                    setState(() {
                      _donationReminders = value;
                    });
                  },
                  activeColor: AppColors.primaryRed,
                ),
              ),
              _buildSettingsItem(
                context,
                'Critical blood shortage notifications',
                'Emergency alerts for urgent needs',
                Icons.warning,
                AppColors.warning,
                trailing: Switch(
                  value: _emergencyAlerts,
                  onChanged: (value) {
                    setState(() {
                      _emergencyAlerts = value;
                    });
                  },
                  activeColor: AppColors.primaryRed,
                ),
              ),
            ],
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Privacy & Security Section
            Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryColor(context),
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsItem(
              context,
              'Location Services',
              'Allow location access for tracking',
              Icons.location_on,
              AppColors.success,
              trailing: Switch(
                value: _locationTracking,
                onChanged: (value) {
                  setState(() {
                    _locationTracking = value;
                  });
                },
                activeColor: AppColors.primaryRed,
              ),
            ),
            _buildSettingsItem(
              context,
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              AppColors.textSecondary,
              onTap: () {
                _showComingSoonDialog('Privacy Policy');
              },
            ),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // About Section
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryColor(context),
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsItem(
              context,
              'App Version',
              '1.0.0 (Build 1)',
              Icons.info,
              AppColors.info,
            ),
            _buildSettingsItem(
              context,
              'Terms of Service',
              'Read our terms and conditions',
              Icons.description,
              AppColors.textSecondary,
              onTap: () {
                _showComingSoonDialog('Terms of Service');
              },
            ),
            
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: HoverButton(
        baseColor: AppColors.getCardBackgroundColor(context),
        onPressed: onTap ?? () {},
        padding: const EdgeInsets.all(AppSizes.paddingM),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppSizes.iconM,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) 
              trailing
            else 
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.getTextSecondaryColor(context),
                size: AppSizes.iconS,
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        title: Text(
          'Select Language',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return HoverButton(
              baseColor: AppColors.getCardBackgroundColor(context),
              onPressed: () {
                setState(() {
                  _selectedLanguage = language;
                });
                Navigator.of(context).pop();
                if (language == 'বাংলা (Bengali)') {
                  _showComingSoonDialog('Bengali Language Support');
                }
              },
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingS,
                horizontal: AppSizes.paddingM,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: Row(
                children: [
                  Radio<String>(
                    value: language,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                      Navigator.of(context).pop();
                      if (value == 'বাংলা (Bengali)') {
                        _showComingSoonDialog('Bengali Language Support');
                      }
                    },
                    activeColor: AppColors.primaryRed,
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Expanded(
                    child: Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.getTextSecondaryColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        title: Text(
          'Coming Soon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          '$feature will be available in a future update.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getTextSecondaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}