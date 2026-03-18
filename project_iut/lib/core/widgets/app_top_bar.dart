import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showNotification;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const AppTopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.showNotification = false,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: AppColors.getSurfaceColor(context),
      foregroundColor: AppColors.getTextPrimaryColor(context),
      title: Row(
        children: [
          // Left-most back button (if can pop)
          if (showBack && Navigator.of(context).canPop())
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.paddingM),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.getTextPrimaryColor(context)),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            )
          else
            const SizedBox(width: AppSizes.paddingM),

          // Page title aligned to the left, padded
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSizes.paddingS),
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.getTextPrimaryColor(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Notification icon (if enabled)
          if (showNotification)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingS),
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                    onPressed: onNotificationTap,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationCount > 9 ? '9+' : notificationCount.toString(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // App logo + name on the rightmost, padded
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingM),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryRed,
                  child: Icon(Icons.bloodtype, size: 16, color: AppColors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      elevation: 0.5,
    );
  }
}
