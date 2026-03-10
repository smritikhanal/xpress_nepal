import '../models/cart_item.dart';

abstract class CartRepo {
  Future<List<CartItem>> getCart();
  Future<void> addToCart(String productId, double price, {Map<String, dynamic>? selectedAttributes});
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeFromCart(String productId);
  Future<void> clearCart();
}
