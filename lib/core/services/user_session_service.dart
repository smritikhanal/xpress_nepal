import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';

/// Service for managing user session state and persistence
/// Handles login/logout operations and session data management
class UserSessionService {
  // Singleton pattern
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  Box<UserModel>? _usersBox;
  Box<dynamic>? _sessionBox;
  UserModel? _currentUser;

  /// Initialize the service with Hive boxes
  /// Must be called after Hive is initialized and boxes are opened
  Future<void> init({
    required Box<UserModel> usersBox,
    required Box<dynamic> sessionBox,
  }) async {
    _usersBox = usersBox;
    _sessionBox = sessionBox;

    // Load current user from session
    await _loadCurrentUser();
  }

  /// Load current user from session storage
  Future<void> _loadCurrentUser() async {
    if (_sessionBox == null || _usersBox == null) {
      throw Exception('UserSessionService not initialized. Call init() first.');
    }

    final userId = _sessionBox!.get(HiveConstants.currentUserIdKey);
    if (userId != null) {
      _currentUser = _usersBox!.get(userId);
    }
  }

  /// Get the currently logged-in user
  UserModel? get currentUser => _currentUser;

  /// Check if a user is currently logged in
  bool get isLoggedIn => _currentUser != null;

  /// Save the current session after login
  Future<void> saveSession(UserModel user) async {
    if (_sessionBox == null || _usersBox == null) {
      throw Exception('UserSessionService not initialized. Call init() first.');
    }

    // Save user to local database
    await _usersBox!.put(user.id, user);

    // Save session
    await _sessionBox!.put(HiveConstants.currentUserIdKey, user.id);

    // Cache in memory
    _currentUser = user;
  }

  /// Save authentication token to session
  Future<void> saveToken(String token) async {
    if (_sessionBox == null) {
      throw Exception('UserSessionService not initialized. Call init() first.');
    }

    await _sessionBox!.put(HiveConstants.authTokenKey, token);
  }

  /// Get the stored authentication token
  String? getToken() {
    if (_sessionBox == null) {
      return null;
    }
    return _sessionBox!.get(HiveConstants.authTokenKey);
  }

  /// Clear the entire session (logout)
  Future<void> clearSession() async {
    if (_sessionBox == null) {
      throw Exception('UserSessionService not initialized. Call init() first.');
    }

    await _sessionBox!.delete(HiveConstants.currentUserIdKey);
    await _sessionBox!.delete(HiveConstants.authTokenKey);

    _currentUser = null;
  }

  /// Update the current user in memory and storage
  Future<void> updateCurrentUser(UserModel user) async {
    if (_usersBox == null) {
      throw Exception('UserSessionService not initialized. Call init() first.');
    }

    await _usersBox!.put(user.id, user);
    _currentUser = user;
  }

  /// Get a user by ID from local storage
  UserModel? getUserById(String id) {
    if (_usersBox == null) return null;
    return _usersBox!.get(id);
  }

  /// Check if user exists locally by email
  UserModel? findUserByEmail(String email) {
    if (_usersBox == null) return null;

    try {
      return _usersBox!.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase().trim(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear all session data (for testing/reset)
  Future<void> clearAllData() async {
    if (_usersBox == null || _sessionBox == null) {
      throw Exception('UserSessionService not initialized. Call init() first.');
    }

    await _usersBox!.clear();
    await _sessionBox!.clear();
    _currentUser = null;
  }
}
