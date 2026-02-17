import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/notification/data/models/notification_model.dart';
import 'package:xpress_nepal/features/notification/domain/datasources/notification_remote_datasource.dart';
import 'package:xpress_nepal/features/notification/domain/entities/notification_entity.dart';
import 'package:xpress_nepal/features/notification/domain/entities/notifications_result.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService _apiService;

  NotificationRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<NotificationsResult> getNotifications({
    bool unreadOnly = false,
  }) async {
    print('NotificationDataSource: Fetching notifications...');
    final response = await _apiService.get(
      ApiConstants.notifications,
      queryParams: unreadOnly ? {'unreadOnly': 'true'} : null,
      requiresAuth: true,
    );

    print(
      'NotificationDataSource: Response success=${response.success}, data=${response.data}',
    );

    if (response.success && response.data != null) {
      // Handle nested data structure from API
      final data = response.data!;
      final actualData =
          data['data'] ?? data; // Support both nested and flat structure

      final notificationsList = ((actualData['notifications'] as List?) ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      final unreadCount = actualData['unreadCount'] as int? ?? 0;

      print(
        'NotificationDataSource: Parsed ${notificationsList.length} notifications',
      );

      return NotificationsResult(
        notifications: notificationsList,
        unreadCount: unreadCount,
      );
    } else {
      print('NotificationDataSource: Error - ${response.message}');
      throw ApiException(response.message ?? 'Failed to fetch notifications');
    }
  }

  @override
  Future<NotificationEntity> markAsRead(String id) async {
    final response = await _apiService.put(
      ApiConstants.markNotificationRead(id),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return NotificationModel.fromJson(response.data!);
    } else {
      throw ApiException(response.message ?? 'Failed to mark as read');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await _apiService.put(
      ApiConstants.markAllNotificationsRead,
      requiresAuth: true,
    );

    if (!response.success) {
      throw ApiException(response.message ?? 'Failed to mark all as read');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    final response = await _apiService.delete(
      ApiConstants.deleteNotification(id),
      requiresAuth: true,
    );

    if (!response.success) {
      throw ApiException(response.message ?? 'Failed to delete notification');
    }
  }
}
