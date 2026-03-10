import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricSecureCredentials {
  final String userId;
  final String token;

  const BiometricSecureCredentials({required this.userId, required this.token});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'token': token,
  };

  factory BiometricSecureCredentials.fromJson(Map<String, dynamic> json) {
    return BiometricSecureCredentials(
      userId: json['userId'] as String,
      token: json['token'] as String,
    );
  }
}

class BiometricSecureStorageService {
  static const String _biometricCredentialsKey =
      'biometric_auth_secure_credentials';

  final FlutterSecureStorage _storage;

  BiometricSecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  Future<void> saveCredentials(BiometricSecureCredentials credentials) async {
    await _storage.write(
      key: _biometricCredentialsKey,
      value: jsonEncode(credentials.toJson()),
    );
  }

  Future<BiometricSecureCredentials?> readCredentials() async {
    final encoded = await _storage.read(key: _biometricCredentialsKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return BiometricSecureCredentials.fromJson(decoded);
    } catch (_) {
      await clearCredentials();
      return null;
    }
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _biometricCredentialsKey);
  }
}
