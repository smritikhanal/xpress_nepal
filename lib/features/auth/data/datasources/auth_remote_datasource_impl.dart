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
        },
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final token = data['token'] as String?;
        final userJson = data['user'] as Map<String, dynamic>?;

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
        final data = response.data!;
        final token = data['token'] as String?;
        final userJson = data['user'] as Map<String, dynamic>?;

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
}
