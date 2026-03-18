import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const AppTopBar({super.key, required this.title, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
