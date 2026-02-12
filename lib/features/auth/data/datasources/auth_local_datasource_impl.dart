import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_local_datasource.dart';

/// Implementation of AuthLocalDataSource for local Hive storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> _usersBox;
  final Box<dynamic> _sessionBox;
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl({
    required Box<UserModel> usersBox,
    required Box<dynamic> sessionBox,
    FlutterSecureStorage? secureStorage,
  }) : _usersBox = usersBox,
       _sessionBox = sessionBox,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveUser(UserModel user) async {
    await _usersBox.put(user.id, user);
  }

  @override
  UserModel? findUserByEmail(String email) {
    try {
      return _usersBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase().trim(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  UserModel? getUserById(String id) {
    return _usersBox.get(id);
  }

  @override
  Future<void> saveSession(String userId) async {
    await _sessionBox.put(HiveConstants.currentUserIdKey, userId);
  }

  @override
  String? getCurrentSessionUserId() {
    return _sessionBox.get(HiveConstants.currentUserIdKey) as String?;
  }

  @override
  Future<void> clearSession() async {
    await _sessionBox.delete(HiveConstants.currentUserIdKey);
  }

  @override
  bool isLoggedIn() {
    final userId = _sessionBox.get(HiveConstants.currentUserIdKey);
    return userId != null;
  }

  @override
  Future<void> saveToken(String token) async {
    await _sessionBox.put(HiveConstants.authTokenKey, token);
    // Also save to FlutterSecureStorage for ApiClient interceptor
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  @override
  String? getToken() {
    return _sessionBox.get(HiveConstants.authTokenKey) as String?;
  }

  @override
  Future<void> clearToken() async {
    await _sessionBox.delete(HiveConstants.authTokenKey);
    // Also clear from FlutterSecureStorage
    await _secureStorage.delete(key: 'auth_token');
  }
}
