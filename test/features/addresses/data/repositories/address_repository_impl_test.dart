
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/addresses/data/models/address_model.dart';
import 'package:xpress_nepal/features/addresses/data/repositories/address_repository_impl.dart';
import 'package:xpress_nepal/features/addresses/domain/datasources/address_remote_datasource.dart';

class MockAddressRemoteDataSource extends Mock implements AddressRemoteDataSource {}

void main() {
  late AddressRepositoryImpl repository;
  late MockAddressRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAddressRemoteDataSource();
    repository = AddressRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tAddressModel = AddressModel(
    id: '1',
    userId: 'u1',
    fullName: 'Test User',
    phone: '1234567890',
    country: 'Nepal',
    state: 'Bagmati',
    city: 'Kathmandu',
    street: 'Street 1',
    isDefault: true,
  );

  group('getAddresses', () {
    test('should return list of addresses on success', () async {
      // Arrange
      when(() => mockRemoteDataSource.getAddresses()).thenAnswer(
        (_) async => AddressApiResult(success: true, addresses: [tAddressModel]),
      );

      // Act
      final result = await repository.getAddresses();

      // Assert
      expect(result.success, true);
      expect(result.addresses?.first.id, tAddressModel.id);
      verify(() => mockRemoteDataSource.getAddresses()).called(1);
    });

    test('should return failure message on failure', () async {
      // Arrange
      when(() => mockRemoteDataSource.getAddresses()).thenAnswer(
        (_) async => AddressApiResult(success: false, message: 'Failed'),
      );

      // Act
      final result = await repository.getAddresses();

      // Assert
      expect(result.success, false);
      expect(result.message, 'Failed');
    });
  });

  group('addAddress', () {
    test('should call addAddress on remote datasource', () async {
      // Arrange
      when(() => mockRemoteDataSource.addAddress(
        fullName: any(named: 'fullName'),
        phone: any(named: 'phone'),
        country: any(named: 'country'),
        state: any(named: 'state'),
        city: any(named: 'city'),
        street: any(named: 'street'),
      )).thenAnswer(
        (_) async => AddressApiResult(success: true, address: tAddressModel),
      );

      // Act
      final result = await repository.addAddress(
        fullName: 'Test User',
        phone: '1234567890',
        country: 'Nepal',
        state: 'Bagmati',
        city: 'Kathmandu',
        street: 'Street 1',
      );

      // Assert
      expect(result.success, true);
      verify(() => mockRemoteDataSource.addAddress(
        fullName: 'Test User',
        phone: '1234567890',
        country: 'Nepal',
        state: 'Bagmati',
        city: 'Kathmandu',
        street: 'Street 1',
      )).called(1);
    });
  });
}