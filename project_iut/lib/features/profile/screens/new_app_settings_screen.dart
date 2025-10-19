import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/hover_button.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';

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

  final List<String> _languages = ['English', 'বাংলা (Bengali)'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: l10n.appSettings),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            Text(
              l10n.appearance,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: l10n.darkMode,
                subtitle: l10n.switchTheme,
                icon: Icons.dark_mode,
                iconColor: AppColors.textSecondary,
                trailing: Consumer(
                  builder: (context, ref, _) {
                    final themeState = ref.watch(themeProvider);
                    return Switch(
                      value: themeState.isDarkMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                      activeThumbColor: AppColors.primaryRed,
                    );
                  },
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final languageState = ref.watch(languageProvider);
                  final currentLanguage = languageState.locale.languageCode == 'en' 
                      ? 'English' 
                      : 'বাংলা (Bengali)';
                  return _buildSettingsTile(
                    title: l10n.language,
                    subtitle: currentLanguage,
                    icon: Icons.language,
                    iconColor: AppColors.info,
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: AppSizes.iconXS,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => _showLanguageDialog(),
                  );
                },
              ),
            ]),            const SizedBox(height: AppSizes.paddingL),
            
            // Notifications Section
            Text(
              l10n.notificationsSettings,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: l10n.pushNotifications,
                subtitle: l10n.receiveAppNotifications,
                icon: Icons.notifications,
                iconColor: AppColors.warning,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeThumbColor: AppColors.primaryRed,
                ),
              ),
              if (_notificationsEnabled) ...[
                _buildSettingsTile(
                  title: l10n.bloodRequestAlerts,
                  subtitle: l10n.urgentBloodRequests,
                  icon: Icons.bloodtype,
                  iconColor: AppColors.primaryRed,
                  trailing: Switch(
                    value: _bloodRequestNotifications,
                    onChanged: (value) {
                      setState(() {
                        _bloodRequestNotifications = value;
                      });
                    },
                    activeThumbColor: AppColors.primaryRed,
                  ),
                ),
                _buildSettingsTile(
                  title: l10n.donationReminders,
                  subtitle: l10n.remindWhenCanDonate,
                  icon: Icons.schedule,
                  iconColor: AppColors.info,
                  trailing: Switch(
                    value: _donationReminders,
                    onChanged: (value) {
                      setState(() {
                        _donationReminders = value;
                      });
                    },
                    activeThumbColor: AppColors.primaryRed,
                  ),
                ),
                _buildSettingsTile(
                  title: l10n.emergencyAlerts,
                  subtitle: l10n.criticalBloodShortage,
                  icon: Icons.warning,
                  iconColor: AppColors.warning,
                  trailing: Switch(
                    value: _emergencyAlerts,
                    onChanged: (value) {
                      setState(() {
                        _emergencyAlerts = value;
                      });
                    },
                    activeThumbColor: AppColors.primaryRed,
                  ),
                ),
              ],
            ]),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Privacy & Security Section
            Text(
              l10n.privacyAndSecurity,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: l10n.locationServices,
                subtitle: l10n.allowLocationAccess,
                icon: Icons.location_on,
                iconColor: AppColors.success,
                trailing: Switch(
                  value: _locationTracking,
                  onChanged: (value) {
                    setState(() {
                      _locationTracking = value;
                    });
                  },
                  activeThumbColor: AppColors.primaryRed,
                ),
              ),
              _buildSettingsTile(
                title: l10n.privacyPolicy,
                subtitle: l10n.readPrivacyPolicy,
                icon: Icons.privacy_tip,
                iconColor: AppColors.textSecondary,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.iconXS,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  _showComingSoonDialog(l10n.privacyPolicy);
                },
              ),
            ]),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // About Section
            Text(
              l10n.about,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            _buildSettingsCard([
              _buildSettingsTile(
                title: l10n.appVersion,
                subtitle: '1.0.0 (Build 1)',
                icon: Icons.info,
                iconColor: AppColors.info,
              ),
              _buildSettingsTile(
                title: l10n.termsOfService,
                subtitle: l10n.readTermsAndConditions,
                icon: Icons.description,
                iconColor: AppColors.textSecondary,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.iconXS,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  _showComingSoonDialog(l10n.termsOfService);
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
    return Card(
      color: AppColors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
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
    final l10n = AppLocalizations.of(context)!;
    final languageState = ref.read(languageProvider);
    final currentLanguage = languageState.locale.languageCode == 'en' ? 'English' : 'বাংলা (Bengali)';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        title: Text(
          l10n.selectLanguage,
          style: const TextStyle(
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
                // Update language using provider
                final newLanguageCode = language == 'English' ? 'en' : 'bn';
                ref.read(languageProvider.notifier).setLanguage(newLanguageCode);
                Navigator.of(context).pop();
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
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      // Update language using provider
                      final newLanguageCode = value == 'English' ? 'en' : 'bn';
                      ref.read(languageProvider.notifier).setLanguage(newLanguageCode);
                      Navigator.of(context).pop();
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
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        title: Text(
          l10n.comingSoon,
          style: const TextStyle(
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
            child: Center(
              child: Text(
                l10n.ok,
                style: const TextStyle(
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