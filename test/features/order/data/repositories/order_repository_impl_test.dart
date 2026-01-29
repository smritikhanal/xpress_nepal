
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/order/data/datasources/order_remote_datasource.dart';
import 'package:xpress_nepal/features/order/data/repositories/order_repository_impl.dart';
import 'package:xpress_nepal/features/order/data/models/order_model.dart';
import 'package:xpress_nepal/features/order/domain/models/order_entity.dart';

class MockOrderRemoteDataSource extends Mock implements OrderRemoteDataSource {}

void main() {
  late OrderRepositoryImpl repository;
  late MockOrderRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockOrderRemoteDataSource();
    repository = OrderRepositoryImpl(mockRemoteDataSource);
  });

  final tShippingAddressModel = ShippingAddressModel(
    fullName: 'Test User',
    phone: '1234567890',
    country: 'Nepal',
    state: 'State',
    city: 'City',
    street: 'Street',
  );

  final tOrderModel = OrderModel(
    id: '1',
    userId: 'u1',
    items: [],
    shippingAddress: tShippingAddressModel,
    paymentMethod: 'COD',
    paymentStatus: 'pending',
    orderStatus: 'pending',
    totalAmount: 100.0,
    createdAt: DateTime.now(),
  );

  group('createOrder', () {
    test('should return created order from remote datasource', () async {
      // Arrange
      when(() => mockRemoteDataSource.createOrder(any())).thenAnswer((_) async => tOrderModel);

      // Act
      final result = await repository.createOrder(
        shippingAddressId: 'addr1',
        paymentMethod: 'COD',
      );

      // Assert
      expect(result.id, tOrderModel.id);
      verify(() => mockRemoteDataSource.createOrder(any())).called(1);
    });
  });

  group('getMyOrders', () {
    test('should return list of orders', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyOrders(any(), any())).thenAnswer((_) async => [tOrderModel]);

      // Act
      final result = await repository.getMyOrders();

      // Assert
      expect(result, [tOrderModel]);
      verify(() => mockRemoteDataSource.getMyOrders(1, 10)).called(1);
    });
  });
}