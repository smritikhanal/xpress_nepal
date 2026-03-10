import 'package:flutter/material.dart';
import 'package:xpress_nepal/features/notification/domain/repositories/notification_repository.dart';
import 'package:xpress_nepal/features/notification/presentation/state/notification_state.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  NotificationState _state = const NotificationState();

  NotificationViewModel({required NotificationRepository repository})
    : _repository = repository;

  NotificationState get state => _state;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_state.isLoading && !refresh) return;

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      print('NotificationViewModel: Loading notifications...');
      final result = await _repository.getNotifications();
      print(
        'NotificationViewModel: Received ${result.notifications.length} notifications, unread: ${result.unreadCount}',
      );
      _state = _state.copyWith(
        isLoading: false,
        notifications: result.notifications,
        unreadCount: result.unreadCount,
      );
    } catch (e) {
      print('NotificationViewModel: Error loading notifications: $e');
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      final updatedNotification = await _repository.markAsRead(id);

      // Update local state
      final updatedList = _state.notifications.map((n) {
        if (n.id == id) {
          return updatedNotification;
        }
        return n;
      }).toList();

      // Decrement unread count if it was unread
      final wasUnread =
          _state.notifications
              .firstWhere(
                (n) => n.id == id,
                orElse: () => updatedNotification,
              ) // Fallback shouldn't happen if id valid
              .isRead ==
          false;

      final newCount = wasUnread
          ? (_state.unreadCount > 0 ? _state.unreadCount - 1 : 0)
          : _state.unreadCount;

      _state = _state.copyWith(
        notifications: updatedList,
        unreadCount: newCount,
      );
      notifyListeners();
    } catch (e) {
      // Handle error quietly or expose via state if needed
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications(refresh: true);
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);

      final updatedList = _state.notifications
          .where((n) => n.id != id)
          .toList();
      final newCount = updatedList.where((n) => !n.isRead).length;

      _state = _state.copyWith(
        notifications: updatedList,
        unreadCount: newCount,
      );
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
