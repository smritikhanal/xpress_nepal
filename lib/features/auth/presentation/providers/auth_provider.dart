import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:xpress_nepal/features/auth/data/datasources/auth_remote_datasource_impl.dart';
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
  late final ApiService _apiService;

  AuthProvider._internal();

  /// Get singleton instance
  static AuthProvider get instance {
    _instance ??= AuthProvider._internal();
    return _instance!;
  }

  /// Set mock instance for testing
  @visibleForTesting
  static set instance(AuthProvider? mock) {
    _instance = mock;
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

    // Create secure storage
    const secureStorage = FlutterSecureStorage();

    // Create local data source
    final localDataSource = AuthLocalDataSourceImpl(
      usersBox: usersBox,
      sessionBox: sessionBox,
      secureStorage: secureStorage,
    );

    // Create API service
    _apiService = ApiService();

    // Restore auth token if exists
    final storedToken = localDataSource.getToken();
    if (storedToken != null) {
      _apiService.setAuthToken(storedToken);
      // Ensure token is also in secure storage for ApiClient
      await secureStorage.write(key: 'auth_token', value: storedToken);
    }

    // Create remote data source
    final remoteDataSource = AuthRemoteDataSourceImpl(apiService: _apiService);

    // Create repository
    _authRepository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    // Create view model
    _authViewModel = AuthViewModel(authRepository: _authRepository);
  }

  /// Get the auth repository
  AuthRepository get authRepository => _authRepository;

  /// Get the auth view model
  AuthViewModel get authViewModel => _authViewModel;

  /// Get the API service
  ApiService get apiService => _apiService;

  /// Check if user is logged in
  bool get isLoggedIn => _authRepository.isLoggedIn();
}
