import 'package:xpress_nepal/features/auth/domain/datasources/auth_local_datasource.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_remote_datasource.dart';
import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';
import 'package:xpress_nepal/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
/// Handles business logic for authentication operations using remote API
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
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
        // User is already a UserModel, save directly
        await _localDataSource.saveUser(result.user!);

        // Save session with user ID
        await _localDataSource.saveSession(result.user!.id);

        // Save token to session
        if (result.token != null) {
          await _localDataSource.saveToken(result.token!);
        }

        return AuthResult.success(
          message: result.message ?? 'Account created successfully',
          user: result.user!.toEntity(),
        );
      }

      return AuthResult.failure(result.message ?? 'Registration failed');
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
      // Call remote API to login
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        // User is already a UserModel, save directly
        await _localDataSource.saveUser(result.user!);

        // Save session with user ID
        await _localDataSource.saveSession(result.user!.id);

        // Save token to session
        if (result.token != null) {
          await _localDataSource.saveToken(result.token!);
        }

        return AuthResult.success(
          message: result.message ?? 'Login successful',
          user: result.user!.toEntity(),
        );
      }

      return AuthResult.failure(result.message ?? 'Login failed');
    } catch (e) {
      return AuthResult.failure(
        'An error occurred during login: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    // Call remote logout
    await _remoteDataSource.logout();

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

  /// Get the stored auth token
  String? getToken() {
    return _localDataSource.getToken();
  }
}
