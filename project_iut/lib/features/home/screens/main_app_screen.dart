import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import 'home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../notifications/providers/notification_provider.dart';

class MainAppScreen extends ConsumerStatefulWidget {
  const MainAppScreen({super.key});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure currentIndex is always valid after tab removal
    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
    }

    // Get unread notification count
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    
    // Handle back button - on back press, go to home tab if not already there
    return PopScope(
      canPop: _currentIndex == 0, // Allow pop only if on home tab
      onPopInvoked: (didPop) {
        if (!didPop && _currentIndex != 0) {
          // If we didn't pop and not on home, switch to home tab
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusL),
              topRight: Radius.circular(AppSizes.radiusL),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.lightRed,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNotificationIcon(unreadCount),
                label: 'Notifications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Placeholder widget for screens not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppTopBar(title: title, showBack: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.primaryRed,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming soon...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
