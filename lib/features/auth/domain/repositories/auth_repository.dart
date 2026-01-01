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
  });

  /// Login with email and password
  Future<AuthResult> login({required String email, required String password});

  /// Logout current user
  Future<void> logout();

  /// Check if a user is currently logged in
  bool isLoggedIn();

  /// Get the currently logged-in user
  UserEntity? getCurrentUser();
}
