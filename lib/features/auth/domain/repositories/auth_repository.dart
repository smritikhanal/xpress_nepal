import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';

/// Authentication result containing success status, message, and optional user
class AuthResult {
  final bool success;
  final String? message;
  final UserEntity? user;

  const AuthResult({required this.success, this.message, this.user});

  factory AuthResult.success({String? message, UserEntity? user}) {
    return AuthResult(success: true, message: message, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

/// Abstract repository defining authentication operations
/// This is a contract that the data layer must implement
abstract class AuthRepository {
  /// Register a new user with name, email, and password
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role,
    String? shopName,
    String? businessDescription,
  });

  /// Login with email and password
  Future<AuthResult> login({required String email, required String password});

  /// Logout current user
  Future<void> logout();

  /// Check if a user is currently logged in
  bool isLoggedIn();

  /// Get the currently logged-in user
  UserEntity? getCurrentUser();

  /// Get the currently stored authentication token
  String? getCurrentToken();

  /// Restore an authenticated session from a previously issued token
  /// (for example after successful biometric unlock).
  Future<AuthResult> loginWithStoredToken({
    required String userId,
    required String token,
  });

  /// Update user profile (name, phone, image)
  Future<AuthResult> updateProfile({
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
}
