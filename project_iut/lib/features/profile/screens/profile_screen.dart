import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app_router.dart';
import '../../../core/core.dart';
import 'edit_profile_screen.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/hover_button.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../location/screens/location_tracking_screen.dart';
import 'my_activities_screen.dart';
import 'new_app_settings_screen.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppTopBar(title: l10n.profile, showBack: false),
      body: profileAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noUserDataFound,
                    style: TextStyle(
                      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: AppSizes.paddingM,
              bottom: AppSizes.paddingM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Profile Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: _buildProfileHeader(context, user, isDarkMode),
                ),
                
                const SizedBox(height: AppSizes.paddingL),
                
                // Your Impact Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: Text(
                    l10n.yourImpact,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSizes.paddingL),
                
                // Statistics Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: _buildStatisticsSection(context, statsAsync, isDarkMode),
                ),
                
                const SizedBox(height: AppSizes.paddingL),
                
                // Settings & Support
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: _buildSettingsSection(context, ref, isDarkMode),
                ),
                
                const SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingProfile,
                style: TextStyle(
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: TextStyle(
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProfileProvider.notifier).loadUserProfile(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed,
            AppColors.primaryRed.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildInitialsAvatar(user.name),
          ),
          
          const SizedBox(width: AppSizes.paddingM),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.bloodGroup != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      '${user.bloodGroup} Blood Group',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Edit Profile Button
          HoverButton(
            baseColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            padding: const EdgeInsets.all(AppSizes.paddingS),
            borderRadius: BorderRadius.circular(50), // Makes it circular
            child: const Icon(
              Icons.edit,
              color: AppColors.primaryRed,
              size: AppSizes.iconM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, AsyncValue<UserStats> statsAsync, bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: statsAsync.when(
        data: (stats) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        l10n.livesSaved,
                        '${stats.livesSaved}',
                        Icons.favorite,
                        AppColors.primaryRed,
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        l10n.lastDonation,
                        _getLastDonationText(stats.lastDonationDate, l10n),
                        Icons.bloodtype,
                        AppColors.info,
                        isDarkMode,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              // My Activities Button
              HoverButton(
                baseColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyActivitiesScreen(),
                    ),
                  );
                },
                padding: const EdgeInsets.all(AppSizes.paddingM),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(color: AppColors.grey.withOpacity(0.2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingS),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppColors.warning,
                        size: AppSizes.iconM,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    Expanded(
                      flex: 3,
                      child: Text(
                        l10n.myActivities,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          size: AppSizes.iconS,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingL),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Text(
              l10n.unableToLoadStatistics,
              style: TextStyle(
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconL),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSizes.paddingM, bottom: AppSizes.paddingS),
          child: Text(
            l10n.settingsAndSupport,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        _buildSettingsItem(
          context,
          l10n.locationTracking,
          Icons.location_on,
          AppColors.success,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LocationTrackingScreen(),
              ),
            );
          },
          isDarkMode,
        ),
        _buildSettingsItem(
          context,
          l10n.appSettings,
          Icons.settings,
          isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewAppSettingsScreen(),
              ),
            );
          },
          isDarkMode,
        ),
        
        const SizedBox(height: AppSizes.paddingM),
        
        // Logout Button
        HoverButton(
          baseColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
          onPressed: () async {
            _showLogoutDialog(context, ref, isDarkMode);
          },
          padding: const EdgeInsets.all(AppSizes.paddingM),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: AppColors.primaryRed),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                color: AppColors.primaryRed,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                l10n.logout,
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSizes.paddingM),
        
        // Version Info
        Center(
          child: Text(
            l10n.version,
            style: TextStyle(
              color: (isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary).withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: HoverButton(
        baseColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
        onPressed: onTap,
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              size: AppSizes.iconS,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    String initials = name
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primaryRed,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLastDonationText(DateTime? lastDonationDate, AppLocalizations l10n) {
    if (lastDonationDate == null) return l10n.never;
    
    final now = DateTime.now();
    final difference = now.difference(lastDonationDate).inDays;
    
    if (difference < 30) {
      return '${difference}d ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference / 365).floor();
      return '${years}yr ago';
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.logoutConfirmTitle, 
          style: TextStyle(color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              // Store context reference before async operations
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final goRouter = GoRouter.of(context);
              
              // Close the confirmation dialog first
              navigator.pop();
              
              try {
                debugPrint('🚪 ProfileScreen: Logout initiated');
                
                // Sign out the user
                await ref.read(authStateProvider.notifier).signOut();
                debugPrint('✅ ProfileScreen: Sign out complete');
                
                // Wait a bit for auth state to propagate
                await Future.delayed(const Duration(milliseconds: 200));
                
                // Navigate to login - force replace the entire stack
                debugPrint('🔄 ProfileScreen: Navigating to login');
                goRouter.go(AppRoutes.login);
                
              } catch (e) {
                debugPrint('❌ ProfileScreen: Logout error: $e');
                
                // Show error message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
