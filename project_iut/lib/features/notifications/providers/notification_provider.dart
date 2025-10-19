import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

// Notification State
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

// Notification Notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    _loadNotifications();
  }

  // Load notifications for current user
  Future<void> _loadNotifications() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'User not authenticated',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await SupabaseService.from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final notifications = (response as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    try {
      await SupabaseService.from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await SupabaseService.from('notifications')
          .delete()
          .eq('id', notificationId);

      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

// Computed providers
final unreadNotificationCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationProvider);
  return state.unreadCount;
});

final unreadNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final state = ref.watch(notificationProvider);
  return state.notifications.where((n) => !n.isRead).toList();
});
