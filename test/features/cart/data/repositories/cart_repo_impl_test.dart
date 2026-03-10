import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/cart/data/datasource/cart_remote_datasource.dart';
import 'package:xpress_nepal/features/cart/data/models/cart_item_model.dart';
import 'package:xpress_nepal/features/cart/data/repositories/cart_repo_impl.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  late CartRepoImpl repository;
  late MockCartRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCartRemoteDataSource();
    repository = CartRepoImpl(mockRemoteDataSource);
  });

  group('getCart', () {
    test('should return list of cart items from remote datasource', () async {
      // Arrange
      final tCartItems = [
        CartItemModel(
          productId: 'p1',
          quantity: 1,
          productName: 'Product 1',
          priceAtTime: 100,
          productImage: 'img',
          selectedAttributes: {},
        ),
      ];
      when(
        () => mockRemoteDataSource.fetchCart(),
      ).thenAnswer((_) async => tCartItems);

      // Act
      final result = await repository.getCart();

      // Assert
      expect(result, tCartItems);
      verify(() => mockRemoteDataSource.fetchCart()).called(1);
    });
  });

  group('addToCart', () {
    test('should call addToCart on remote datasource', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.addToCart(
          any(),
          any(),
          selectedAttributes: any(named: 'selectedAttributes'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await repository.addToCart('p1', 100);

      // Assert
      verify(() => mockRemoteDataSource.addToCart('p1', 100)).called(1);
    });
  });
}
