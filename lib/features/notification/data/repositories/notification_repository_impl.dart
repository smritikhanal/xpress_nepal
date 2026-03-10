import 'package:xpress_nepal/features/notification/domain/datasources/notification_remote_datasource.dart';
import 'package:xpress_nepal/features/notification/domain/entities/notification_entity.dart';
import 'package:xpress_nepal/features/notification/domain/entities/notifications_result.dart';
import 'package:xpress_nepal/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<NotificationsResult> getNotifications({bool unreadOnly = false}) {
    return _remoteDataSource.getNotifications(unreadOnly: unreadOnly);
  }

  @override
  Future<NotificationEntity> markAsRead(String id) {
    return _remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String id) {
    return _remoteDataSource.deleteNotification(id);
  }
}
