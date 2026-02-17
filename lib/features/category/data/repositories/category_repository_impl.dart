import 'package:xpress_nepal/features/category/data/datasources/category_remote_datasource.dart';
import 'package:xpress_nepal/features/category/domain/entities/category_entity.dart';
import 'package:xpress_nepal/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl({required CategoryRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }
}
