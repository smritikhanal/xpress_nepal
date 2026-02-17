import 'package:xpress_nepal/features/notification/domain/entities/notification_entity.dart';

class NotificationsResult {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationsResult({
    required this.notifications,
    required this.unreadCount,
  });
}
