import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.getSurfaceColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
        iconTheme: IconThemeData(
          color: AppColors.getTextPrimaryColor(context),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (notificationState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${notificationState.error}'),
                      const SizedBox(height: AppSizes.paddingM),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(notificationProvider.notifier).refreshNotifications();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : notificationState.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: AppColors.getTextSecondaryColor(context),
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              color: AppColors.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(notificationProvider.notifier).refreshNotifications();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        itemCount: notificationState.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notificationState.notifications[index];
                          return _NotificationCard(
                            notification: notification,
                            onTap: () {
                              if (!notification.isRead) {
                                ref.read(notificationProvider.notifier).markAsRead(notification.id);
                              }
                            },
                            onDelete: () {
                              ref.read(notificationProvider.notifier).deleteNotification(notification.id);
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: const Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.getCardBackgroundColor(context)
              : AppColors.primaryRed.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: notification.isRead
                ? AppColors.getBorderColor(context)
                : AppColors.primaryRed.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondaryColor(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.bloodRequest:
        return Icons.bloodtype;
      case NotificationType.donationReceived:
        return Icons.favorite;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.bloodRequest:
        return AppColors.primaryRed;
      case NotificationType.donationReceived:
        return AppColors.success;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.system:
        return AppColors.info;
    }
  }
}
