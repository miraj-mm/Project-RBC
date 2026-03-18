enum NotificationType {
  bloodRequest,
  donationReceived,
  reminder,
  system,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseNotificationType(json['type'] as String),
      relatedId: json['related_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'blood_request':
        return NotificationType.bloodRequest;
      case 'donation_received':
        return NotificationType.donationReceived;
      case 'reminder':
        return NotificationType.reminder;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': _notificationTypeToString(type),
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.bloodRequest:
        return 'blood_request';
      case NotificationType.donationReceived:
        return 'donation_received';
      case NotificationType.reminder:
        return 'reminder';
      case NotificationType.system:
        return 'system';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel{id: $id, title: $title, isRead: $isRead}';
  }
}
