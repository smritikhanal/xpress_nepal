import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiEndpoints {
  ApiEndpoints._();

  // Toggle this to switch between emulator and physical device
  static const bool useEmulator = false;

  // Your computer's local IP for physical device testing
  static const String localNetworkIp = '192.168.1.5'; // change to your PC IP

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    try {
      if (Platform.isAndroid) {
        if (useEmulator) {
          return 'http://10.0.2.2:5000/api'; // Android emulator
        } else {
          return 'http://$localNetworkIp:5000/api'; // Physical device
        }
      } else if (Platform.isIOS) {
        return 'http://localhost:5000/api';
      }
    } catch (e) {
      return 'http://localhost:5000/api';
    }

    return 'http://localhost:5000/api';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);

  //login signup endpoints
  static const String userRegister = '/auth/register';
  static const String userLogin = '/auth/login';
  static const String updateProfile = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Message endpoints
  static const String sendMessage = '/messages';
  static const String getInbox = '/messages/inbox';
  static const String getSentMessages = '/messages/sent';
  static String markMessageAsRead(String id) => '/messages/$id/read';
  static String deleteMessage(String id) => '/messages/$id';

  // Notification endpoints
  static const String getNotifications = '/notifications';
  static String markNotificationAsRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsAsRead = '/notifications/read-all';
  static String deleteNotification(String id) => '/notifications/$id';

  // Review endpoints
  static const String getReviews = '/reviews';
  static const String createReview = '/reviews';
  static String deleteReview(String id) => '/reviews/$id';

  // Product endpoints
  static const String getProducts = '/products';
  static String getProductBySlug(String slug) => '/products/$slug';
  static String getProductById(String id) => '/products/id/$id';

  // Category endpoints
  static const String getCategories = '/categories';
  static String getCategoryBySlug(String slug) => '/categories/$slug';

  // User/Seller endpoints
  static const String getUsers = '/users';
  static String getUserById(String id) => '/users/$id';
}
