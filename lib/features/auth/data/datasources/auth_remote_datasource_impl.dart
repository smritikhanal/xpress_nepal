import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<AuthApiResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
    String? shopName,
    String? businessDescription,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        body: {
          'name': name.trim(),
          'email': email.toLowerCase().trim(),
          'password': password,
          'role': role,
          if (phone != null) 'phone': phone,
          if (shopName != null) 'shopName': shopName.trim(),
          if (businessDescription != null)
            'businessDescription': businessDescription.trim(),
        },
      );

      if (response.success && response.data != null) {
        // Backend returns: { success, message, data: { token, user } }
        final responseBody = response.data!;
        final nestedData = responseBody['data'] as Map<String, dynamic>?;

        if (nestedData != null) {
          final token = nestedData['token'] as String?;
          final userJson = nestedData['user'] as Map<String, dynamic>?;

          if (userJson != null && token != null) {
            _apiService.setAuthToken(token);

            final user = UserModel.fromJson(userJson, token: token);

            return AuthApiResult(
              success: true,
              message: response.message ?? 'Registration successful',
              user: user,
              token: token,
            );
          }
        }
      }

      return AuthApiResult(
        success: false,
        message: response.message ?? 'Registration failed',
      );
    } catch (e) {
      return AuthApiResult(
        success: false,
        message: 'Registration error: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthApiResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        body: {'email': email.toLowerCase().trim(), 'password': password},
      );

      if (response.success && response.data != null) {
        // Backend returns: { success, message, data: { token, user } }
        final responseBody = response.data!;
        final nestedData = responseBody['data'] as Map<String, dynamic>?;

        if (nestedData != null) {
          final token = nestedData['token'] as String?;
          final userJson = nestedData['user'] as Map<String, dynamic>?;

          if (userJson != null && token != null) {
            _apiService.setAuthToken(token);

            final user = UserModel.fromJson(userJson, token: token);

            return AuthApiResult(
              success: true,
              message: response.message ?? 'Login successful',
              user: user,
              token: token,
            );
          }
        }
      }

      return AuthApiResult(
        success: false,
        message: response.message ?? 'Login failed',
      );
    } catch (e) {
      return AuthApiResult(
        success: false,
        message: 'Login error: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } finally {
      _apiService.clearAuthToken();
    }
  }

  @override
  Future<AuthApiResult> updateProfile({
    required String name,
    String? phone,
    String? image,
    String? shopName,
    String? businessDescription,
  }) async {
    try {
      final ApiResponse<Map<String, dynamic>> response;

      if (image != null) {
        // Use multipart request if image is provided
        final fields = <String, String>{'name': name.trim()};
        if (phone != null && phone.isNotEmpty) fields['phone'] = phone;
        if (shopName != null && shopName.isNotEmpty)
          fields['shopName'] = shopName;
        if (businessDescription != null)
          fields['businessDescription'] = businessDescription;

        response = await _apiService.putMultipart(
          ApiConstants.updateProfile,
          file: File(image),
          fieldName: 'image',
          fields: fields,
          requiresAuth: true,
        );
      } else {
        // Use regular PUT request if no image
        response = await _apiService.put(
          ApiConstants.updateProfile,
          body: {
            'name': name.trim(),
            if (phone != null && phone.isNotEmpty) 'phone': phone,
            if (shopName != null && shopName.isNotEmpty) 'shopName': shopName,
            if (businessDescription != null)
              'businessDescription': businessDescription,
          },
          requiresAuth: true,
        );
      }

      if (response.success && response.data != null) {
        final responseBody = response.data!;
        final userData = responseBody['data'] as Map<String, dynamic>?;

        if (userData != null) {
          final user = UserModel.fromJson(userData);

          return AuthApiResult(
            success: true,
            message: response.message ?? 'Profile updated successfully',
            user: user,
          );
        }
      }

      return AuthApiResult(
        success: false,
        message: response.message ?? 'Profile update failed',
      );
    } catch (e) {
      return AuthApiResult(
        success: false,
        message: 'Profile update error: ${e.toString()}',
      );
    }
  }

  /// Returns the web app base URL for password reset links.
  /// On web: uses the current browser origin (e.g. http://localhost:50094).
  /// On mobile: uses the configured API base without /api suffix.
  String _getRedirectUrl() {
    if (kIsWeb) {
      final base = Uri.base;
      final port = base.port;
      final portSuffix = (port != 80 && port != 443 && port != 0)
          ? ':$port'
          : '';
      return '${base.scheme}://${base.host}$portSuffix';
    }
    // For Android emulator the API is at 10.0.2.2:5000; web app on same machine
    // is accessible via localhost from the host — use the same host with app port.
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {}
    return 'http://localhost:5000';
  }

  @override
  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.forgotPassword,
        body: {
          'email': email.toLowerCase().trim(),
          'redirectUrl': _getRedirectUrl(),
        },
      );

      return response.success;
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  @override
  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.resetPassword,
        body: {'token': token, 'password': password},
      );

      return response.success;
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}
