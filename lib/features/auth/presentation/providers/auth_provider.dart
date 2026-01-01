import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xpress_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:xpress_nepal/features/auth/presentation/view_model/auth_view_model.dart';

/// Provider class for creating and managing auth dependencies
/// Uses simple dependency injection pattern
class AuthProvider {
  static AuthProvider? _instance;

  late final AuthRepository _authRepository;
  late final AuthViewModel _authViewModel;

  AuthProvider._internal();

  /// Get singleton instance
  static AuthProvider get instance {
    _instance ??= AuthProvider._internal();
    return _instance!;
  }

  /// Initialize the provider with Hive boxes
  /// Must be called after Hive is initialized
  Future<void> initialize() async {
    // Open boxes if not already open
    final usersBox = Hive.isBoxOpen(HiveConstants.usersBox)
        ? Hive.box<UserModel>(HiveConstants.usersBox)
        : await Hive.openBox<UserModel>(HiveConstants.usersBox);

    final sessionBox = Hive.isBoxOpen(HiveConstants.sessionBox)
        ? Hive.box(HiveConstants.sessionBox)
        : await Hive.openBox(HiveConstants.sessionBox);

    // Create data source
    final localDataSource = AuthLocalDataSourceImpl(
      usersBox: usersBox,
      sessionBox: sessionBox,
    );

    // Create repository
    _authRepository = AuthRepositoryImpl(localDataSource: localDataSource);

    // Create view model
    _authViewModel = AuthViewModel(authRepository: _authRepository);
  }

  /// Get the auth repository
  AuthRepository get authRepository => _authRepository;

  /// Get the auth view model
  AuthViewModel get authViewModel => _authViewModel;

  /// Check if user is logged in
  bool get isLoggedIn => _authRepository.isLoggedIn();
}
