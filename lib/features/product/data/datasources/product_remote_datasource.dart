import 'dart:io';
import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/product/data/models/product_model.dart';
import 'package:xpress_nepal/features/product/data/models/review_model.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';

abstract class ProductRemoteDataSource {
  Future<List<ReviewEntity>> fetchProductReviews(String productId);
  Future<ReviewEntity> createReview({
    required String productId,
    required int rating,
    required String comment,
  });
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? sellerId,
    String? search,
    String? sort,
  });

  Future<ProductModel?> getProductById(String id);

  Future<ProductModel?> getProductBySlug(String slug);

  Future<ProductModel> createProduct({
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

  Future<ProductModel> updateProduct({
    required String id,
    String? title,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    int? stock,
    String? brand,
    List<String>? images,
    Map<String, dynamic>? attributes,
    bool? isActive,
  });

  Future<void> deleteProduct(String id);

  Future<String> uploadImage(File file);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ReviewEntity>> fetchProductReviews(String productId) async {
    final response = await _apiService.get(
      '${ApiConstants.apiUrl}/reviews',
      queryParams: {'productId': productId},
    );
    if (response.success && response.data != null) {
      final data = response.data!['data'];
      final List<dynamic> list = data['reviews'] as List<dynamic>;
      return list.map((json) => ReviewModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to fetch reviews');
    }
  }

  final ApiService _apiService;

  ProductRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? sellerId,
    String? search,
    String? sort,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (categoryId != null) queryParams['category'] = categoryId;
    if (sellerId != null) queryParams['sellerId'] = sellerId;
    if (search != null) queryParams['search'] = search;
    if (sort != null) queryParams['sort'] = sort;

    final response = await _apiService.get(
      '${ApiConstants.apiUrl}/products',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      final List<dynamic> productsJson =
          response.data!['data']['products'] as List? ?? [];
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to fetch products');
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final response = await _apiService.get(
      '${ApiConstants.apiUrl}/products/id/$id',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data!['data']);
    }
    return null;
  }

  @override
  Future<ProductModel?> getProductBySlug(String slug) async {
    final response = await _apiService.get(
      '${ApiConstants.apiUrl}/products/$slug',
    );

    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data!['data']);
    }
    return null;
  }

  @override
  Future<ProductModel> createProduct({
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
    // Generate simplified slug based on title (basic implementation)
    // Backend should ideally handle duplicates/uniqueness
    // Generate unique slug based on title + timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final slug =
        '${title.toLowerCase().replaceAll(RegExp(r'\s+'), '-')}-$timestamp';

    final body = {
      'title': title,
      'slug': slug,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'categoryId': categoryId,
      'stock': stock,
      'brand': brand,
      'images': images,
    };

    if (attributes != null && attributes.isNotEmpty) {
      final serializedAttributes = <String, dynamic>{};
      attributes.forEach((key, options) {
        serializedAttributes[key] = options
            .map(
              (opt) => {'value': opt.value, 'priceModifier': opt.priceModifier},
            )
            .toList();
      });
      body['attributes'] = serializedAttributes;
    }

    body.removeWhere((key, value) => value == null);

    final response = await _apiService.post(
      '${ApiConstants.apiUrl}/products',
      body: body,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data!['data']);
    } else {
      throw Exception(response.message ?? 'Failed to create product');
    }
  }

  @override
  Future<ProductModel> updateProduct({
    required String id,
    String? title,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    int? stock,
    String? brand,
    List<String>? images,
    Map<String, dynamic>? attributes,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price;
    if (discountPrice != null) body['discountPrice'] = discountPrice;
    if (categoryId != null) body['categoryId'] = categoryId;
    if (stock != null) body['stock'] = stock;
    if (brand != null) body['brand'] = brand;
    if (images != null) body['images'] = images;
    if (attributes != null) body['attributes'] = attributes;
    if (isActive != null) body['isActive'] = isActive;

    final response = await _apiService.put(
      '${ApiConstants.apiUrl}/products/$id',
      body: body,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data!['data']);
    } else {
      throw Exception(response.message ?? 'Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final response = await _apiService.delete(
      '${ApiConstants.apiUrl}/products/id/$id',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete product');
    }
  }

  @override
  Future<String> uploadImage(File file) async {
    final response = await _apiService.postMultipart(
      '${ApiConstants.apiUrl}/upload',
      file: file,
      fieldName: 'image',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!['data']['url'] as String;
    } else {
      throw Exception(response.message ?? 'Failed to upload image');
    }
  }

  @override
  Future<ReviewEntity> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final response = await _apiService.post(
      '${ApiConstants.apiUrl}/reviews',
      body: {'productId': productId, 'rating': rating, 'comment': comment},
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      // API returns the created review object directly or inside 'data'
      // Based on controller: sendResponse(res, 201, review, 'Review submitted successfully');
      // sendResponse format usually puts data in 'data' field.
      // So response.data!['data'] should be the review object.
      // But wait sendResponse impl isn't visible here, usually it wraps in data.
      // Checking created review in controller:
      // sendResponse(res, 201, review, 'Review submitted successfully');
      // If sendResponse wraps second arg in { success: true, message: ..., data: ... }
      // Then response.data is that wrapper? No, ApiService usually unwraps or gives access to json.
      // Looking at `uploadImage` above: response.data!['data']['url']
      // Looking at `getProducts`: response.data!['data']['products']
      // So it seems `response.data` is the JSON body.
      // If sendResponse(res, code, data, msg) structure is standard:
      // { success: true, message: msg, data: data }
      // So response.data!['data'] should be the review object.
      return ReviewModel.fromJson(response.data!['data']);
    } else {
      throw Exception(response.message ?? 'Failed to submit review');
    }
  }
}
