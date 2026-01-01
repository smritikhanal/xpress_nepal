import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_local_datasource.dart';
import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';
import 'package:xpress_nepal/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
/// Handles business logic for authentication operations
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({required AuthLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

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

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Normalize email
      final normalizedEmail = email.toLowerCase().trim();

      // Check if email already exists
      final existingUser = _localDataSource.findUserByEmail(normalizedEmail);
      if (existingUser != null) {
        return AuthResult.failure('An account with this email already exists');
      }

      // Hash the password
      final passwordHash = _hashPassword(password);

      // Create new user model
      final user = UserModel(
        id: _generateUserId(),
        name: name.trim(),
        email: normalizedEmail,
        passwordHash: passwordHash,
      );

      // Save user to local storage
      await _localDataSource.saveUser(user);

      // Auto-login after signup
      await _localDataSource.saveSession(user.id);

      return AuthResult.success(
        message: 'Account created successfully',
        user: user.toEntity(),
      );
    } catch (e) {
      return AuthResult.failure(
        'An error occurred during registration: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Normalize email
      final normalizedEmail = email.toLowerCase().trim();

      // Find user by email
      final user = _localDataSource.findUserByEmail(normalizedEmail);
      if (user == null) {
        return AuthResult.failure('No account found with this email');
      }

      // Verify password
      final passwordHash = _hashPassword(password);
      if (user.passwordHash != passwordHash) {
        return AuthResult.failure('Invalid password');
      }

      // Save session
      await _localDataSource.saveSession(user.id);

      return AuthResult.success(
        message: 'Login successful',
        user: user.toEntity(),
      );
    } catch (e) {
      return AuthResult.failure(
        'An error occurred during login: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearSession();
  }

  @override
  bool isLoggedIn() {
    return _localDataSource.isLoggedIn();
  }

  @override
  UserEntity? getCurrentUser() {
    final userId = _localDataSource.getCurrentSessionUserId();
    if (userId == null) return null;

    final user = _localDataSource.getUserById(userId);
    return user?.toEntity();
  }
}
