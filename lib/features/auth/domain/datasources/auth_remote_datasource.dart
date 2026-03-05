import 'package:xpress_nepal/features/auth/data/models/user_model.dart';

/// Auth result from remote API
class AuthApiResult {
  final bool success;
  final String? message;
  final UserModel? user;
  final String? token;

  AuthApiResult({required this.success, this.message, this.user, this.token});
}

/// Abstract data source defining remote authentication operations
/// This is a contract for the API data source implementation
abstract class AuthRemoteDataSource {
  /// Register a new user via API
  Future<AuthApiResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role,
    String? shopName,
    String? businessDescription,
  });

  /// Login user via API
  Future<AuthApiResult> login({
    required String email,
    required String password,
  });

  /// Update user profile via API
  Future<AuthApiResult> updateProfile({
    required String name,
    String? phone,
    String? image,
    String? shopName,
    String? businessDescription,
  });

  /// Send forgot password email
  Future<bool> forgotPassword({required String email});

  /// Reset password with token
  Future<bool> resetPassword({required String token, required String password});

  /// Logout user (optional API call)
  Future<void> logout();
}
