import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_local_datasource.dart';

/// Implementation of AuthLocalDataSource using Hive for local storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> _usersBox;
  final Box<dynamic> _sessionBox;

  AuthLocalDataSourceImpl({
    required Box<UserModel> usersBox,
    required Box<dynamic> sessionBox,
  }) : _usersBox = usersBox,
       _sessionBox = sessionBox;

  @override
  Future<void> saveUser(UserModel user) async {
    await _usersBox.put(user.id, user);
  }

  @override
  UserModel? findUserByEmail(String email) {
    try {
      return _usersBox.values.firstWhere(
        (user) => user.email == email.toLowerCase().trim(),
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
    return _sessionBox.get(HiveConstants.currentUserIdKey);
  }

  @override
  Future<void> clearSession() async {
    await _sessionBox.delete(HiveConstants.currentUserIdKey);
  }

  @override
  bool isLoggedIn() {
    return getCurrentSessionUserId() != null;
  }
}
