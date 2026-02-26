import 'dart:math';

import 'package:xpress_nepal/core/services/connectivity/network_info.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_local_datasource.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_remote_datasource.dart';
import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';
import 'package:xpress_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';

/// Implementation of AuthRepository
/// Handles business logic for authentication operations using remote API
class AuthRepositoryImpl implements AuthRepository {
  final INetworkInfo _networkInfo;
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required INetworkInfo networkInfo,
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
  }) : _networkInfo = networkInfo,
       _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
    String? shopName,
    String? businessDescription,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        // Call remote API to register
        final result = await _remoteDataSource.register(
          name: name,
          email: email,
          password: password,
          phone: phone,
          role: role,
          shopName: shopName,
          businessDescription: businessDescription,
        );

        if (result.success && result.user != null) {
          await _persistAuthenticatedUser(result.user!, token: result.token);

          return AuthResult.success(
            message: result.message ?? 'Account created successfully',
            user: result.user!.toEntity(),
          );
        }

        return AuthResult.failure(result.message ?? 'Registration failed');
      }

      return await _signUpOffline(
        name: name,
        email: email,
        phone: phone,
        role: role,
        shopName: shopName,
        businessDescription: businessDescription,
      );
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  Future<AuthResult> _signUpOffline({
    required String name,
    required String email,
    String? phone,
    required String role,
    String? shopName,
    String? businessDescription,
  }) async {
    try {
      final existingUser = _localDataSource.findUserByEmail(email);
      if (existingUser != null) {
        return AuthResult.failure(
          'Account already exists locally. Please connect to the internet to sync.',
        );
      }

      final localUser = UserModel(
        id: _generateOfflineUserId(),
        name: name.trim(),
        email: email.toLowerCase().trim(),
        phone: phone,
        role: role,
        shopName: shopName,
        businessDescription: businessDescription,
        isActive: true,
      );

      await _persistAuthenticatedUser(localUser, token: localUser.token);

      return AuthResult.success(
        message: 'Account created locally while offline.',
        user: localUser.toEntity(),
      );
    } catch (e) {
      return AuthResult.failure('Offline registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        // Call remote API to login
        final result = await _remoteDataSource.login(
          email: email,
          password: password,
        );

        if (result.success && result.user != null) {
          await _persistAuthenticatedUser(result.user!, token: result.token);

          return AuthResult.success(
            message: result.message ?? 'Login successful',
            user: result.user!.toEntity(),
          );
        }

        return AuthResult.failure(result.message ?? 'Login failed');
      }

      return await _loginOffline(email: email);
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResult> _loginOffline({required String email}) async {
    try {
      final localUser = _localDataSource.findUserByEmail(email);
      if (localUser == null) {
        return AuthResult.failure(
          'No local account found. Please connect to the internet and login once.',
        );
      }

      await _persistAuthenticatedUser(localUser, token: localUser.token);

      return AuthResult.success(
        message: 'Logged in using local data (offline mode).',
        user: localUser.toEntity(),
      );
    } catch (e) {
      return AuthResult.failure('Offline login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    final isOnline = await _networkInfo.isConnected;

    // Call remote logout only when online
    if (isOnline) {
      try {
        await _remoteDataSource.logout();
      } catch (_) {
        // Continue local cleanup regardless of API logout failure.
      }
    }

    // Clear local session
    await _localDataSource.clearSession();
    await _localDataSource.clearToken();
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

  @override
  String? getCurrentToken() {
    return _localDataSource.getToken();
  }

  @override
  Future<AuthResult> loginWithStoredToken({
    required String userId,
    required String token,
  }) async {
    try {
      final user = _localDataSource.getUserById(userId);
      if (user == null) {
        return AuthResult.failure(
          'Stored session user could not be found. Please login with password.',
        );
      }

      await _localDataSource.saveSession(userId);
      await _localDataSource.saveToken(token);

      return AuthResult.success(
        message: 'Biometric login successful',
        user: user.toEntity(),
      );
    } catch (e) {
      return AuthResult.failure(
        'Unable to restore session from secure token: ${e.toString()}',
      );
    }
  }

  /// Get the stored auth token
  String? getToken() {
    return _localDataSource.getToken();
  }

  Future<void> _persistAuthenticatedUser(
    UserModel user, {
    String? token,
  }) async {
    await _localDataSource.saveUser(user);
    await _localDataSource.saveSession(user.id);

    final finalToken = token ?? user.token;
    if (finalToken != null && finalToken.isNotEmpty) {
      await _localDataSource.saveToken(finalToken);
    }
  }

  String _generateOfflineUserId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999).toString().padLeft(5, '0');
    return 'offline_$millis$random';
  }
}
