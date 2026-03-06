import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/domain/repositories/product_repository.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';

class ProductViewModel extends ChangeNotifier {
  Future<List<ReviewEntity>> fetchProductReviews(String productId) async {
    return await _productRepository.fetchProductReviews(productId);
  }

  Future<List<ReviewEntity>> fetchMyReviews() async {
    return await _productRepository.fetchMyReviews();
  }

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    await _productRepository.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
    // Refresh logic handled by provider
  }

  final ProductRepository _productRepository;

  ProductState _state = ProductState.initial();
  ProductState get state => _state;

  ProductViewModel({required ProductRepository productRepository})
    : _productRepository = productRepository;

  /// Load products (with pagination support)
  Future<void> loadProducts({
    String? categoryId,
    String? sellerId,
    String? search,
    String? sort,
    bool refresh = false,
  }) async {
    if (refresh) {
      _state = _state.copyWith(
        status: ProductStatus.loading,
        page: 1,
        products: [],
        hasReachedMax: false,
      );
      notifyListeners();
    } else if (_state.hasReachedMax) {
      return;
    }

    try {
      final newProducts = await _productRepository.getProducts(
        page: _state.page,
        limit: 10,
        categoryId: categoryId,
        sellerId: sellerId,
        search: search,
        sort: sort,
      );

      _state = _state.copyWith(
        status: ProductStatus.loaded,
        products: refresh ? newProducts : [..._state.products, ...newProducts],
        hasReachedMax: newProducts.isEmpty || newProducts.length < 10,
        page: _state.page + 1,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }

  /// Get product details
  Future<void> getProductDetails(String id) async {
    _state = _state.copyWith(status: ProductStatus.loading);
    notifyListeners();

    try {
      final product = await _productRepository.getProductById(id);
      if (product != null) {
        _state = _state.copyWith(
          status: ProductStatus.loaded,
          selectedProduct: product,
        );
      } else {
        _state = _state.copyWith(
          status: ProductStatus.error,
          errorMessage: 'Product not found',
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }

  // Create a new product
  Future<bool> createProduct({
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
    _state = _state.copyWith(status: ProductStatus.loading);
    notifyListeners();

    try {
      await _productRepository.createProduct(
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

      _state = _state.copyWith(status: ProductStatus.success);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Update an existing product
  Future<bool> updateProduct({
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
    _state = _state.copyWith(status: ProductStatus.loading);
    notifyListeners();

    try {
      final updatedProduct = await _productRepository.updateProduct(
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

      // Update the product in the list if it exists
      final updatedList = _state.products.map((p) {
        return p.id == id ? updatedProduct : p;
      }).toList();

      _state = _state.copyWith(
        status: ProductStatus.success,
        products: updatedList,
        selectedProduct: updatedProduct,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Upload product image
  Future<String?> uploadImage(File file) async {
    try {
      final url = await _productRepository.uploadImage(file);
      return url;
    } catch (e) {
      _state = _state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return null;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String id) async {
    _state = _state.copyWith(status: ProductStatus.loading);
    notifyListeners();

    try {
      await _productRepository.deleteProduct(id);

      // Remove from list
      final updatedList = _state.products.where((p) => p.id != id).toList();

      _state = _state.copyWith(
        status: ProductStatus.success,
        products: updatedList,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _state = _state.copyWith(status: ProductStatus.initial, errorMessage: null);
    notifyListeners();
  }
}
