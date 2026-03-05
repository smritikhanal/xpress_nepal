import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/core/services/connectivity/network_info.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_local_datasource.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_remote_datasource.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    authRepository = AuthRepositoryImpl(
      networkInfo: mockNetworkInfo,
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tUserModel = UserModel(
    id: '1',
    name: 'Test User',
    email: 'test@email.com',
    role: 'customer',
  );

  group('signUp', () {
    test(
      'should return success when remote data source is successful',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
          ),
        ).thenAnswer(
          (_) async => AuthApiResult(
            success: true,
            user: tUserModel,
            message: 'Success',
          ),
        );

        when(
          () => mockLocalDataSource.saveUser(tUserModel),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.saveSession('1'),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.saveToken(any()),
        ).thenAnswer((_) async {});

        // Act
        final result = await authRepository.signUp(
          name: 'Test User',
          email: 'test@email.com',
          password: 'password',
        );

        // Assert
        expect(result.success, true);
        // toEntity is called inside repo, so we compare Entity
        expect(result.user, tUserModel.toEntity());
        verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
      },
    );

    test('should return failure when remote data source fails', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
        ),
      ).thenAnswer(
        (_) async => AuthApiResult(success: false, message: 'Error'),
      );

      // Act
      final result = await authRepository.signUp(
        name: 'Test User',
        email: 'test@email.com',
        password: 'password',
      );

      // Assert
      expect(result.success, false);
      verifyNever(() => mockLocalDataSource.saveUser(any()));
    });
  });

  group('login', () {
    test(
      'should return success when remote data source is successful',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.login(
            email: 'test@email.com',
            password: 'password',
          ),
        ).thenAnswer(
          (_) async => AuthApiResult(
            success: true,
            user: tUserModel,
            message: 'Success',
          ),
        );

        when(
          () => mockLocalDataSource.saveUser(tUserModel),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.saveSession('1'),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.saveToken(any()),
        ).thenAnswer((_) async {});

        // Act
        final result = await authRepository.login(
          email: 'test@email.com',
          password: 'password',
        );

        // Assert
        expect(result.success, true);
        expect(result.user, tUserModel.toEntity());
        verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
        verify(() => mockLocalDataSource.saveSession('1')).called(1);
      },
    );

    test('should return failure when remote data source fails', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.login(
          email: 'test@email.com',
          password: 'wrongpassword',
        ),
      ).thenAnswer(
        (_) async =>
            AuthApiResult(success: false, message: 'Invalid credentials'),
      );

      // Act
      final result = await authRepository.login(
        email: 'test@email.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result.success, false);
      expect(result.message, 'Invalid credentials');
      verifyNever(() => mockLocalDataSource.saveUser(any()));
      verifyNever(() => mockLocalDataSource.saveSession(any()));
    });

    test('should handle exceptions and return failure', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await authRepository.login(
        email: 'test@email.com',
        password: 'password',
      );

      // Assert
      expect(result.success, false);
      expect(result.message, contains('Login failed'));
      verifyNever(() => mockLocalDataSource.saveUser(any()));
    });

    test('should save token when provided by remote data source', () async {
      // Arrange
      const token = 'test-token-123';
      when(
        () => mockRemoteDataSource.login(
          email: 'test@email.com',
          password: 'password',
        ),
      ).thenAnswer(
        (_) async => AuthApiResult(
          success: true,
          user: tUserModel,
          token: token,
          message: 'Success',
        ),
      );

      when(
        () => mockLocalDataSource.saveUser(tUserModel),
      ).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveSession('1')).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveToken(token)).thenAnswer((_) async {});

      // Act
      await authRepository.login(email: 'test@email.com', password: 'password');

      // Assert
      verify(() => mockLocalDataSource.saveToken(token)).called(1);
    });
  });

  group('signUp - additional cases', () {
    test('should handle exceptions and return failure', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
        ),
      ).thenThrow(Exception('Server error'));

      // Act
      final result = await authRepository.signUp(
        name: 'Test User',
        email: 'test@email.com',
        password: 'password',
      );

      // Assert
      expect(result.success, false);
      expect(result.message, contains('Registration failed'));
      verifyNever(() => mockLocalDataSource.saveUser(any()));
    });

    test('should save token when provided during sign up', () async {
      // Arrange
      const token = 'signup-token-456';
      when(
        () => mockRemoteDataSource.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
        ),
      ).thenAnswer(
        (_) async => AuthApiResult(
          success: true,
          user: tUserModel,
          token: token,
          message: 'Success',
        ),
      );

      when(
        () => mockLocalDataSource.saveUser(tUserModel),
      ).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveSession('1')).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveToken(token)).thenAnswer((_) async {});

      // Act
      await authRepository.signUp(
        name: 'Test User',
        email: 'test@email.com',
        password: 'password',
      );

      // Assert
      verify(() => mockLocalDataSource.saveToken(token)).called(1);
    });

    test('should pass optional seller parameters correctly', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.register(
          name: 'Test Seller',
          email: 'seller@email.com',
          password: 'password',
          role: 'seller',
          phone: '1234567890',
          shopName: 'Test Shop',
          businessDescription: 'Test Description',
        ),
      ).thenAnswer(
        (_) async =>
            AuthApiResult(success: true, user: tUserModel, message: 'Success'),
      );

      when(
        () => mockLocalDataSource.saveUser(tUserModel),
      ).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveSession('1')).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveToken(any())).thenAnswer((_) async {});

      // Act
      final result = await authRepository.signUp(
        name: 'Test Seller',
        email: 'seller@email.com',
        password: 'password',
        role: 'seller',
        phone: '1234567890',
        shopName: 'Test Shop',
        businessDescription: 'Test Description',
      );

      // Assert
      expect(result.success, true);
      verify(
        () => mockRemoteDataSource.register(
          name: 'Test Seller',
          email: 'seller@email.com',
          password: 'password',
          role: 'seller',
          phone: '1234567890',
          shopName: 'Test Shop',
          businessDescription: 'Test Description',
        ),
      ).called(1);
    });
  });

  group('logout', () {
    test('should clear local session and call remote logout', () async {
      // Arrange
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async {});
      when(() => mockLocalDataSource.clearSession()).thenAnswer((_) async {});
      when(() => mockLocalDataSource.clearToken()).thenAnswer((_) async {});

      // Act
      await authRepository.logout();

      // Assert
      verify(() => mockRemoteDataSource.logout()).called(1);
      verify(() => mockLocalDataSource.clearSession()).called(1);
      verify(() => mockLocalDataSource.clearToken()).called(1);
    });

    test(
      'should clear local session without calling remote logout when offline',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocalDataSource.clearSession()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.clearToken()).thenAnswer((_) async {});

        // Act
        await authRepository.logout();

        // Assert
        verifyNever(() => mockRemoteDataSource.logout());
        verify(() => mockLocalDataSource.clearSession()).called(1);
        verify(() => mockLocalDataSource.clearToken()).called(1);
      },
    );
  });

  group('offline fallback', () {
    test('login should use local datasource when offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalDataSource.findUserByEmail('test@email.com'),
      ).thenReturn(tUserModel);
      when(
        () => mockLocalDataSource.saveUser(tUserModel),
      ).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveSession('1')).thenAnswer((_) async {});

      // Act
      final result = await authRepository.login(
        email: 'test@email.com',
        password: 'password',
      );

      // Assert
      expect(result.success, true);
      verifyNever(
        () => mockRemoteDataSource.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      verify(
        () => mockLocalDataSource.findUserByEmail('test@email.com'),
      ).called(1);
      verify(() => mockLocalDataSource.saveSession('1')).called(1);
    });

    test('signUp should create local user when offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalDataSource.findUserByEmail('offline@email.com'),
      ).thenReturn(null);
      when(() => mockLocalDataSource.saveUser(any())).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.saveSession(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await authRepository.signUp(
        name: 'Offline User',
        email: 'offline@email.com',
        password: 'password',
      );

      // Assert
      expect(result.success, true);
      verifyNever(
        () => mockRemoteDataSource.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
        ),
      );
      verify(
        () => mockLocalDataSource.findUserByEmail('offline@email.com'),
      ).called(1);
      verify(() => mockLocalDataSource.saveUser(any())).called(1);
      verify(() => mockLocalDataSource.saveSession(any())).called(1);
    });
  });

  group('isLoggedIn', () {
    test('should return true when user is logged in', () {
      // Arrange
      when(() => mockLocalDataSource.isLoggedIn()).thenReturn(true);

      // Act
      final result = authRepository.isLoggedIn();

      // Assert
      expect(result, true);
      verify(() => mockLocalDataSource.isLoggedIn()).called(1);
    });

    test('should return false when user is not logged in', () {
      // Arrange
      when(() => mockLocalDataSource.isLoggedIn()).thenReturn(false);

      // Act
      final result = authRepository.isLoggedIn();

      // Assert
      expect(result, false);
      verify(() => mockLocalDataSource.isLoggedIn()).called(1);
    });
  });

  group('getCurrentUser', () {
    test('should return user when session exists', () {
      // Arrange
      when(() => mockLocalDataSource.getCurrentSessionUserId()).thenReturn('1');
      when(() => mockLocalDataSource.getUserById('1')).thenReturn(tUserModel);

      // Act
      final result = authRepository.getCurrentUser();

      // Assert
      expect(result, isNotNull);
      expect(result?.id, tUserModel.id);
      expect(result?.name, tUserModel.name);
      expect(result?.email, tUserModel.email);
      verify(() => mockLocalDataSource.getCurrentSessionUserId()).called(1);
      verify(() => mockLocalDataSource.getUserById('1')).called(1);
    });

    test('should return null when no session exists', () {
      // Arrange
      when(
        () => mockLocalDataSource.getCurrentSessionUserId(),
      ).thenReturn(null);

      // Act
      final result = authRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(() => mockLocalDataSource.getCurrentSessionUserId()).called(1);
      verifyNever(() => mockLocalDataSource.getUserById(any()));
    });

    test('should return null when user not found in local storage', () {
      // Arrange
      when(() => mockLocalDataSource.getCurrentSessionUserId()).thenReturn('1');
      when(() => mockLocalDataSource.getUserById('1')).thenReturn(null);

      // Act
      final result = authRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(() => mockLocalDataSource.getCurrentSessionUserId()).called(1);
      verify(() => mockLocalDataSource.getUserById('1')).called(1);
    });
  });

  group('getToken', () {
    test('should return token when available', () {
      // Arrange
      const token = 'test-token-789';
      when(() => mockLocalDataSource.getToken()).thenReturn(token);

      // Act
      final result = authRepository.getToken();

      // Assert
      expect(result, token);
      verify(() => mockLocalDataSource.getToken()).called(1);
    });

    test('should return null when token is not available', () {
      // Arrange
      when(() => mockLocalDataSource.getToken()).thenReturn(null);

      // Act
      final result = authRepository.getToken();

      // Assert
      expect(result, isNull);
      verify(() => mockLocalDataSource.getToken()).called(1);
    });
  });
}
