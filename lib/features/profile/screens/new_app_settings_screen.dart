import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/hover_button.dart';

class NewAppSettingsScreen extends ConsumerStatefulWidget {
  const NewAppSettingsScreen({super.key});

  @override
  ConsumerState<NewAppSettingsScreen> createState() => _NewAppSettingsScreenState();
}

class _NewAppSettingsScreenState extends ConsumerState<NewAppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _bloodRequestNotifications = true;
  bool _donationReminders = true;
  bool _emergencyAlerts = true;
  bool _locationTracking = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'বাংলা (Bengali)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'App Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                icon: Icons.dark_mode,
                iconColor: AppColors.textSecondary,
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    _showComingSoonDialog('Dark Mode');
                  },
                  activeColor: AppColors.primaryRed,
                ),
              ),
              _buildSettingsTile(
                title: 'Language',
                subtitle: _selectedLanguage,
                icon: Icons.language,
                iconColor: AppColors.info,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.iconXS,
                  color: AppColors.textSecondary,
                ),
                onTap: () => _showLanguageDialog(),
              ),
            ]),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Notifications Section
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: 'Push Notifications',
                subtitle: 'Receive app notifications',
                icon: Icons.notifications,
                iconColor: AppColors.warning,
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
                _buildSettingsTile(
                  title: 'Blood Request Alerts',
                  subtitle: 'Get notified about urgent blood requests',
                  icon: Icons.bloodtype,
                  iconColor: AppColors.primaryRed,
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
                _buildSettingsTile(
                  title: 'Donation Reminders',
                  subtitle: 'Remind me when I can donate again',
                  icon: Icons.schedule,
                  iconColor: AppColors.info,
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
                _buildSettingsTile(
                  title: 'Emergency Alerts',
                  subtitle: 'Critical blood shortage notifications',
                  icon: Icons.warning,
                  iconColor: AppColors.warning,
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
            ]),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Privacy & Security Section
            const Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: 'Location Services',
                subtitle: 'Allow location access for tracking',
                icon: Icons.location_on,
                iconColor: AppColors.success,
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
              _buildSettingsTile(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                icon: Icons.privacy_tip,
                iconColor: AppColors.textSecondary,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.iconXS,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  _showComingSoonDialog('Privacy Policy');
                },
              ),
            ]),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // About Section
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: 'App Version',
                subtitle: '1.0.0 (Build 1)',
                icon: Icons.info,
                iconColor: AppColors.info,
              ),
              _buildSettingsTile(
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                icon: Icons.description,
                iconColor: AppColors.textSecondary,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.iconXS,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  _showComingSoonDialog('Terms of Service');
                },
              ),
            ]),
            
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return HoverButton(
      baseColor: AppColors.white,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        title: const Text(
          'Select Language',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return HoverButton(
              baseColor: AppColors.white,
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        title: const Text(
          'Coming Soon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '$feature will be available in a future update. Stay tuned!',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          HoverButton(
            baseColor: AppColors.primaryRed,
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingS,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: const Center(
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}