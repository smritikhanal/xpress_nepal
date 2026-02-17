import 'package:flutter/foundation.dart';

class ImageHelper {
  static String fixImageUrl(String url) {
    if (kIsWeb) {
      // Replace Android emulator loopback IP with localhost for Web
      if (url.contains('10.0.2.2')) {
        return url.replaceFirst('10.0.2.2', 'localhost');
      }
    }
    return url;
  }
}
