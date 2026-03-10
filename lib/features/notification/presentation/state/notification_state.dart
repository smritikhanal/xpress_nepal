import 'package:xpress_nepal/features/notification/domain/entities/notification_entity.dart';

class NotificationState {
  final bool isLoading;
  final String? errorMessage;
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationState({
    this.isLoading = false,
    this.errorMessage,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<NotificationEntity>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
