import 'package:flutter/foundation.dart';
import 'package:xpress_nepal/core/constants/api_constants.dart';

class ImageHelper {
  static String fixImageUrl(String url) {
    if (url.trim().isEmpty) return url;

    var normalizedUrl = url.trim().replaceAll('\\', '/');

    // Handle protocol-relative URLs (e.g. //cdn.example.com/image.jpg)
    if (normalizedUrl.startsWith('//')) {
      normalizedUrl = 'https:$normalizedUrl';
    }

    // Convert relative upload paths from DB to absolute backend URL
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      if (!normalizedUrl.startsWith('/')) {
        normalizedUrl = '/$normalizedUrl';
      }

      if (normalizedUrl.startsWith('/uploads/')) {
        normalizedUrl = '${ApiConstants.baseUrl}$normalizedUrl';
      }
    }

    if (kIsWeb) {
      // Replace Android emulator loopback IP with localhost for Web
      if (normalizedUrl.contains('10.0.2.2')) {
        return normalizedUrl.replaceFirst('10.0.2.2', 'localhost');
      }
    }

    return normalizedUrl;
  }
}
