import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> fetchCart();
  Future<void> addToCart(String productId, double price, {Map<String, dynamic>? selectedAttributes});
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeItem(String productId);
  Future<void> clearCart();
}
