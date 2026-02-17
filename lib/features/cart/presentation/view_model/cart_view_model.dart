import 'package:flutter/foundation.dart';
import '../../domain/repositories/cart_repo.dart';
import '../state/cart_state.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepo _repo;

  CartState _state = CartState.initial();
  CartState get state => _state;

  CartViewModel({required CartRepo repo}) : _repo = repo {
    loadCart();
  }

  Future<void> loadCart() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      final items = await _repo.getCart();
      _state = _state.copyWith(items: items, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  Future<void> addToCart(String productId, double price, {Map<String, dynamic>? selectedAttributes}) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      await _repo.addToCart(productId, price, selectedAttributes: selectedAttributes);
      await loadCart();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      await _repo.updateQuantity(productId, quantity);
      await loadCart();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      await _repo.removeFromCart(productId);
      await loadCart();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
      notifyListeners();
    }
  }
  
  Future<void> clearCart() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      await _repo.clearCart();
      _state = _state.copyWith(items: [], isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }
}
