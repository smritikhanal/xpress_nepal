import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';

class ProductReviewsState {
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? error;

  ProductReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  ProductReviewsState copyWith({
    List<ReviewEntity>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return ProductReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
