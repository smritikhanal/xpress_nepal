// lib/features/auth/data/datasources/user_datasource.dart

import 'package:xpress_nepal/features/auth/data/models/user_api_model.dart';
import '../../domain/entities/user_entity.dart';

/// ================= LOCAL DATA SOURCE =================
abstract class IUserLocalDataSource {
  /// Register/save a user locally (returns updated user)
  Future<UserEntity> registerUser(UserEntity user);

  /// Login user locally (usually via cached credentials/token)
  Future<UserEntity> loginUser(String email, String password);

  /// Get locally stored user by ID
  Future<UserEntity?> getUserById(String id);

  /// Update locally stored user
  Future<bool> updateUser(UserEntity user);

  /// Delete locally stored user
  Future<bool> deleteUser(String id);

  /// Logout user (clear local cache/token)
  Future<bool> logout();
}

/// ================= REMOTE DATA SOURCE =================
abstract class IUserRemoteDataSource {
  /// Register user remotely
  Future<UserApiModel> registerUser(UserApiModel user);

  /// Login user remotely
  Future<UserApiModel> loginUser(String email, String password);

  /// Fetch user by ID from API
  Future<UserApiModel?> getUserById(String id);

  /// Update user remotely
  Future<bool> updateUser(UserApiModel user);

  /// Delete user remotely
  Future<bool> deleteUser(String id);

  /// Logout user remotely (invalidate token if supported)
  Future<bool> logout();
}
