import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, loaded, success, error }

class ProductState {
  final ProductStatus status;
  final List<ProductEntity> products; // For lists
  final ProductEntity? selectedProduct; // For details/editing
  final String? errorMessage;
  final bool hasReachedMax;
  final int page;

  ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.selectedProduct,
    this.errorMessage,
    this.hasReachedMax = false,
    this.page = 1,
  });

  factory ProductState.initial() => ProductState();

  factory ProductState.loading() => ProductState(status: ProductStatus.loading);

  factory ProductState.error(String message) =>
      ProductState(status: ProductStatus.error, errorMessage: message);

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    String? errorMessage,
    bool? hasReachedMax,
    int? page,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }
}
