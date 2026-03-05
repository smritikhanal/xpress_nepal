import 'dart:io';
import 'package:xpress_nepal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';
import 'package:xpress_nepal/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ReviewEntity>> fetchProductReviews(String productId) async {
    return await _remoteDataSource.fetchProductReviews(productId);
  }

  @override
  Future<ReviewEntity> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    return await _remoteDataSource.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }

  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProductEntity>> getProducts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? sellerId,
    String? search,
    String? sort,
  }) async {
    final products = await _remoteDataSource.getProducts(
      page: page,
      limit: limit,
      categoryId: categoryId,
      sellerId: sellerId,
      search: search,
      sort: sort,
    );
    return products; // Models are Entities in Dart
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return await _remoteDataSource.getProductById(id);
  }

  @override
  Future<ProductEntity?> getProductBySlug(String slug) async {
    return await _remoteDataSource.getProductBySlug(slug);
  }

  @override
  Future<ProductEntity> createProduct({
    required String title,
    required String description,
    required double price,
    double? discountPrice,
    required String categoryId,
    required int stock,
    String? brand,
    List<String>? images,
    Map<String, List<AttributeOption>>? attributes,
  }) async {
    return await _remoteDataSource.createProduct(
      title: title,
      description: description,
      price: price,
      discountPrice: discountPrice,
      categoryId: categoryId,
      stock: stock,
      brand: brand,
      images: images,
      attributes: attributes,
    );
  }

  @override
  Future<ProductEntity> updateProduct({
    required String id,
    String? title,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    int? stock,
    String? brand,
    List<String>? images,
    Map<String, List<AttributeOption>>? attributes,
    bool? isActive,
  }) async {
    return await _remoteDataSource.updateProduct(
      id: id,
      title: title,
      description: description,
      price: price,
      discountPrice: discountPrice,
      categoryId: categoryId,
      stock: stock,
      brand: brand,
      images: images,
      attributes: attributes,
      isActive: isActive,
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
  }

  @override
  Future<String> uploadImage(File file) async {
    return await _remoteDataSource.uploadImage(file);
  }
}
