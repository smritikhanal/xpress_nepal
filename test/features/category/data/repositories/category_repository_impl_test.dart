import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/category/data/datasources/category_remote_datasource.dart';
import 'package:xpress_nepal/features/category/data/repositories/category_repository_impl.dart';
import 'package:xpress_nepal/features/category/data/models/category_model.dart';

class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tCategoryModel = CategoryModel(
    id: '1',
    name: 'Electronics',
    image: 'img-url',
    slug: 'electronics',
  );

  group('getCategories', () {
    test('should return list of categories from remote data source', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.getCategories(),
      ).thenAnswer((_) async => [tCategoryModel]);

      // Act
      final result = await repository.getCategories();

      // Assert
      expect(result, [tCategoryModel]);
      verify(() => mockRemoteDataSource.getCategories()).called(1);
    });
  });
}
