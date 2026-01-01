import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/data/models/user_model.dart';
import 'package:xpress_nepal/data/services/hive_service.dart';

/// Result class for authentication operations
class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  AuthResult({required this.success, this.message, this.user});
}

/// Service class for handling authentication operations
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HiveService _hiveService = HiveService();

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a unique ID for users
  String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Register a new user
  /// Returns AuthResult with success status and message
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Normalize email to lowercase
      final normalizedEmail = email.toLowerCase().trim();

      // Check if email already exists
      final existingUser = _findUserByEmail(normalizedEmail);
      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: 'An account with this email already exists',
        );
      }

      // Hash the password
      final passwordHash = _hashPassword(password);

      // Create new user
      final user = UserModel(
        id: _generateUserId(),
        name: name.trim(),
        email: normalizedEmail,
        passwordHash: passwordHash,
      );

      // Save user to Hive
      await _hiveService.usersBox.put(user.id, user);

      // Auto-login after signup
      await _saveSession(user.id);

      return AuthResult(
        success: true,
        message: 'Account created successfully',
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An error occurred during registration: ${e.toString()}',
      );
    }
  }

  /// Login with email and password
  /// Returns AuthResult with success status and message
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Normalize email to lowercase
      final normalizedEmail = email.toLowerCase().trim();

      // Find user by email
      final user = _findUserByEmail(normalizedEmail);
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'No account found with this email',
        );
      }

      // Verify password
      final passwordHash = _hashPassword(password);
      if (user.passwordHash != passwordHash) {
        return AuthResult(success: false, message: 'Invalid password');
      }

      // Save session
      await _saveSession(user.id);

      return AuthResult(success: true, message: 'Login successful', user: user);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An error occurred during login: ${e.toString()}',
      );
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _hiveService.sessionBox.delete(HiveConstants.currentUserIdKey);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    final userId = _hiveService.sessionBox.get(HiveConstants.currentUserIdKey);
    return userId != null;
  }

  /// Get current logged-in user
  UserModel? getCurrentUser() {
    final userId = _hiveService.sessionBox.get(HiveConstants.currentUserIdKey);
    if (userId == null) return null;
    return _hiveService.usersBox.get(userId);
  }

  /// Find user by email
  UserModel? _findUserByEmail(String email) {
    try {
      return _hiveService.usersBox.values.firstWhere(
        (user) => user.email == email,
      );
    } catch (e) {
      return null;
    }
  }

  /// Save user session
  Future<void> _saveSession(String userId) async {
    await _hiveService.sessionBox.put(HiveConstants.currentUserIdKey, userId);
  }
}
