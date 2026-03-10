import 'package:flutter/material.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/home/data/wishlist_service.dart';
import 'package:xpress_nepal/core/api/api_client.dart';

class WishlistProvider extends ChangeNotifier {
  final List<ProductEntity> _wishlist = [];
  final WishlistService _service;
  bool _loading = false;
  String? _error;

  List<ProductEntity> get wishlist => List.unmodifiable(_wishlist);
  bool get loading => _loading;
  String? get error => _error;

  WishlistProvider(ApiClient apiClient)
    : _service = WishlistService(apiClient) {
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await _service.fetchWishlist();
      _wishlist
        ..clear()
        ..addAll(items);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool isWishlisted(ProductEntity product) {
    return _wishlist.any((p) => p.id == product.id);
  }

  Future<void> addToWishlist(ProductEntity product) async {
    try {
      await _service.addToWishlist(product.id);
      if (!isWishlisted(product)) {
        _wishlist.add(product);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(ProductEntity product) async {
    try {
      await _service.removeFromWishlist(product.id);
      _wishlist.removeWhere((p) => p.id == product.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(ProductEntity product) async {
    if (isWishlisted(product)) {
      await removeFromWishlist(product);
    } else {
      await addToWishlist(product);
    }
  }
}
