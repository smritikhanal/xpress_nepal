
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_local_datasource.dart';
import 'package:xpress_nepal/features/auth/domain/datasources/auth_remote_datasource.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xpress_nepal/features/auth/domain/repositories/auth_repository.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    authRepository = AuthRepositoryImpl(
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
    test('should return success when remote data source is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        role: any(named: 'role'),
      )).thenAnswer((_) async => AuthApiResult(success: true, user: tUserModel, message: 'Success'));
      
      when(() => mockLocalDataSource.saveUser(tUserModel)).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveSession('1')).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveToken(any())).thenAnswer((_) async {});

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
    });

    test('should return failure when remote data source fails', () async {
      // Arrange
      when(() => mockRemoteDataSource.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        role: any(named: 'role'),
      )).thenAnswer((_) async => AuthApiResult(success: false, message: 'Error'));

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
      test('should return success when remote data source is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(
          email: 'test@email.com',
          password: 'password',
        )).thenAnswer((_) async => AuthApiResult(success: true, user: tUserModel, message: 'Success'));
        
        when(() => mockLocalDataSource.saveUser(tUserModel)).thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveSession('1')).thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveToken(any())).thenAnswer((_) async {});

        // Act
        final result = await authRepository.login(
          email: 'test@email.com',
          password: 'password',
        );

        if (!result.success) {
          print('Login failed with message: ${result.message}');
        }

        // Assert
        expect(result.success, true);
        verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
      });
  });
}