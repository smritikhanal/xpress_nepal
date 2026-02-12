import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// API Constants for backend connectivity
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // Base URL - determined by platform
  // For Web: localhost
  // For Android emulator: 10.0.2.2
  // For iOS simulator: localhost
  // For real device: your computer's IP address
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    // For mobile platforms
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000';
      } else if (Platform.isIOS) {
        return 'http://localhost:5000';
      }
    } catch (e) {
      // Fallback for web where Platform is not available
      return 'http://localhost:5000';
    }
    return 'http://localhost:5000';
  }

  // API version
  static const String apiVersion = '/api';

  // Full API URL
  static String get apiUrl => '$baseUrl$apiVersion';

  // Auth endpoints
  static String get register => '$apiUrl/auth/register';
  static String get login => '$apiUrl/auth/login';
  static String get logout => '$apiUrl/auth/logout';

  // User endpoints
  static String get users => '$apiUrl/users';
  static String get userProfile => '$apiUrl/users/profile';

  // Address endpoints
  static String get addresses => '$apiUrl/addresses';

  // Notification endpoints
  static String get notifications => '$apiUrl/notifications';
  static String get markAllNotificationsRead =>
      '$apiUrl/notifications/read-all';
  static String markNotificationRead(String id) =>
      '$apiUrl/notifications/$id/read';
  static String deleteNotification(String id) => '$apiUrl/notifications/$id';

  // Message endpoints
  static String get messages => '$apiUrl/messages';
  static String get messageInbox => '$apiUrl/messages/inbox';
  static String get messageSent => '$apiUrl/messages/sent';
  static String get messageUnreadCount => '$apiUrl/messages/unread';
  static String markMessageRead(String id) => '$apiUrl/messages/$id/read';
  static String deleteMessage(String id) => '$apiUrl/messages/$id';

  // Timeout durations (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}
