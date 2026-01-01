import 'package:xpress_nepal/features/auth/data/models/user_model.dart';

/// Abstract data source defining local authentication operations
/// This is a contract for the local data source implementation
abstract class AuthLocalDataSource {
  /// Save a new user to local storage
  Future<void> saveUser(UserModel user);

  /// Find a user by email
  UserModel? findUserByEmail(String email);

  /// Get a user by ID
  UserModel? getUserById(String id);

  /// Save user session (store logged-in user ID)
  Future<void> saveSession(String userId);

  /// Get current session user ID
  String? getCurrentSessionUserId();

  /// Clear user session (logout)
  Future<void> clearSession();

  /// Check if user is logged in
  bool isLoggedIn();
}
