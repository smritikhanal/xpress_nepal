import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// API Constants for backend connectivity
class ApiConstants {
  ApiConstants._();

  /// Optional compile-time override
  /// Example:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Toggle this when switching devices
  /// true  -> Android Emulator
  /// false -> Physical device
  static const bool useEmulator = false;

  /// Your computer's local IP (for physical device)
  static const String deviceIp = '192.168.1.5';

  /// Base URL logic
  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    try {
      if (Platform.isAndroid) {
        return useEmulator ? 'http://10.0.2.2:5000' : 'http://$deviceIp:5000';
      } else if (Platform.isIOS) {
        return 'http://localhost:5000';
      }
    } catch (e) {
      return 'http://localhost:5000';
    }

    return 'http://localhost:5000';
  }

  /// API version
  static const String apiVersion = '/api';

  /// Full API URL
  static String get apiUrl => '$baseUrl$apiVersion';

  // ---------------- AUTH ----------------
  static String get register => '$apiUrl/auth/register';
  static String get login => '$apiUrl/auth/login';
  static String get logout => '$apiUrl/auth/logout';
  static String get updateProfile => '$apiUrl/auth/me';
  static String get forgotPassword => '$apiUrl/auth/forgot-password';
  static String get resetPassword => '$apiUrl/auth/reset-password';
  static String get changePassword => '$apiUrl/auth/change-password';

  // ---------------- USERS ----------------
  static String get users => '$apiUrl/users';
  static String get userProfile => '$apiUrl/users/profile';

  // ---------------- PRODUCTS ----------------
  static String get products => '$apiUrl/products';
  static String productBySlug(String slug) => '$apiUrl/products/$slug';
  static String productById(String id) => '$apiUrl/products/id/$id';

  // ---------------- REVIEWS ----------------
  static String get reviews => '$apiUrl/reviews';
  static String get myReviews => '$apiUrl/reviews/my-reviews';
  static String deleteReview(String id) => '$apiUrl/reviews/$id';

  // ---------------- ADDRESSES ----------------
  static String get addresses => '$apiUrl/addresses';

  // ---------------- NOTIFICATIONS ----------------
  static String get notifications => '$apiUrl/notifications';
  static String get markAllNotificationsRead =>
      '$apiUrl/notifications/read-all';
  static String markNotificationRead(String id) =>
      '$apiUrl/notifications/$id/read';
  static String deleteNotification(String id) => '$apiUrl/notifications/$id';

  // ---------------- MESSAGES ----------------
  static String get messages => '$apiUrl/messages';
  static String get messageInbox => '$apiUrl/messages/inbox';
  static String get messageSent => '$apiUrl/messages/sent';
  static String get messageUnreadCount => '$apiUrl/messages/unread';
  static String markMessageRead(String id) => '$apiUrl/messages/$id/read';
  static String get markAllMessagesRead => '$apiUrl/messages/read-all';
  static String deleteMessage(String id) => '$apiUrl/messages/$id';

  // ---------------- TIMEOUT ----------------
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}
