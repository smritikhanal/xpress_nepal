import 'package:flutter/material.dart';
import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_reviews_state.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';

class ProductReviewsProvider extends ChangeNotifier {
  ProductReviewsState _state = ProductReviewsState();
  ProductReviewsState get state => _state;

  Future<void> fetchReviews(String productId) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final reviews = await ProductProvider.instance.productViewModel
          .fetchProductReviews(productId);
      _state = _state.copyWith(reviews: reviews, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(error: e.toString(), isLoading: false);
    }
    notifyListeners();
  }
}
