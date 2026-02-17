import 'package:flutter/foundation.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:xpress_nepal/features/product/data/repositories/product_repository_impl.dart';
import 'package:xpress_nepal/features/product/domain/repositories/product_repository.dart';
import 'package:xpress_nepal/features/product/presentation/view_model/product_view_model.dart';

/// Provider for product-related dependencies
class ProductProvider {
  static ProductProvider? _instance;
  static ProductProvider get instance => _instance ??= ProductProvider._();

  /// Set mock instance for testing
  @visibleForTesting
  static set instance(ProductProvider? mock) {
    _instance = mock;
  }

  ProductProvider._();

  late ProductRemoteDataSource _remoteDataSource;
  late ProductRepository _productRepository;
  late ProductViewModel _productViewModel;

  bool _isInitialized = false;

  /// Initialize all product dependencies
  Future<void> initialize() async {
    if (_isInitialized) return;

    final apiService = ApiService();

    _remoteDataSource = ProductRemoteDataSourceImpl(apiService: apiService);
    _productRepository = ProductRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );
    _productViewModel = ProductViewModel(productRepository: _productRepository);

    _isInitialized = true;
  }

  /// Get product view model
  ProductViewModel get productViewModel {
    if (!_isInitialized) {
      throw StateError(
        'ProductProvider not initialized. Call initialize() first.',
      );
    }
    return _productViewModel;
  }

  /// Get product repository
  ProductRepository get productRepository {
    if (!_isInitialized) {
      throw StateError(
        'ProductProvider not initialized. Call initialize() first.',
      );
    }
    return _productRepository;
  }
}
