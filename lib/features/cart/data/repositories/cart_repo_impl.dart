import '../../domain/models/cart_item.dart';
import '../../domain/repositories/cart_repo.dart';
import '../datasource/cart_remote_datasource.dart';

class CartRepoImpl implements CartRepo {
  final CartRemoteDataSource remote;

  CartRepoImpl(this.remote);

  @override
  Future<List<CartItem>> getCart() async {
    return await remote.fetchCart();
  }

  @override
  Future<void> addToCart(String productId, double price, {Map<String, dynamic>? selectedAttributes}) {
    return remote.addToCart(productId, price, selectedAttributes: selectedAttributes);
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) {
    return remote.updateQuantity(productId, quantity);
  }

  @override
  Future<void> removeFromCart(String productId) {
    return remote.removeItem(productId);
  }

  @override
  Future<void> clearCart() {
    return remote.clearCart();
  }
}
