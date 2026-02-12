import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - determined by platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
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
}
