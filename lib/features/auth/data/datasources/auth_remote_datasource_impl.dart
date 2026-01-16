import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_remote_datasource.dart';

/// Implementation of AuthRemoteDataSource using API service
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
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      body: {
        'name': name.trim(),
        'email': email.toLowerCase().trim(),
        'password': password,
        'phone': phone ?? '',
        'role': role,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (userData != null && token != null) {
        final user = UserModel.fromJson(userData, token: token);

        // Set the auth token for future requests
        _apiService.setAuthToken(token);

        return AuthApiResult(
          success: true,
          message: response.message ?? 'Registration successful',
          user: user,
          token: token,
        );
      }
    }

    return AuthApiResult(
      success: false,
      message: response.message ?? 'Registration failed',
    );
  }

  @override
  Future<AuthApiResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      body: {'email': email.toLowerCase().trim(), 'password': password},
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (userData != null && token != null) {
        final user = UserModel.fromJson(userData, token: token);

        // Set the auth token for future requests
        _apiService.setAuthToken(token);

        return AuthApiResult(
          success: true,
          message: response.message ?? 'Login successful',
          user: user,
          token: token,
        );
      }
    }

    return AuthApiResult(
      success: false,
      message: response.message ?? 'Login failed',
    );
  }

  @override
  Future<void> logout() async {
    // Clear the auth token
    _apiService.clearAuthToken();

    // Optionally call the logout endpoint
    await _apiService.post(ApiConstants.logout);
  }
}
