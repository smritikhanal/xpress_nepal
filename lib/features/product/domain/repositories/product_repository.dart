import 'dart:io';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';

/// Abstract contract for Product Repository
/// Defines what operations are available without specifying how they are implemented
abstract class ProductRepository {
  /// Get all reviews for a product
  Future<List<ReviewEntity>> fetchProductReviews(String productId);

  /// Get all reviews submitted by the current user
  Future<List<ReviewEntity>> fetchMyReviews();

  /// Create a review
  Future<ReviewEntity> createReview({
    required String productId,
    required int rating,
    required String comment,
  });

  /// Get all products with optional filters
  Future<List<ProductEntity>> getProducts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? sellerId,
    String? search,
    String? sort,
  });

  /// Get a single product by ID
  Future<ProductEntity?> getProductById(String id);

  /// Get a single product by Slug
  Future<ProductEntity?> getProductBySlug(String slug);

  /// Create a new product
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
  });

  /// Update an existing product
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
  });

  /// Delete a product
  Future<void> deleteProduct(String id);

  /// Upload an image
  Future<String> uploadImage(File file);
}
