import 'package:xpress_nepal/features/notification/domain/entities/notification_entity.dart';
import 'package:xpress_nepal/features/notification/domain/entities/notifications_result.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationsResult> getNotifications({bool unreadOnly = false});
  Future<NotificationEntity> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}
