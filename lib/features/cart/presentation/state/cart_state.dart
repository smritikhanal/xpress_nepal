import '../../domain/models/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  factory CartState.initial() => const CartState();

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
  
  double get totalPrice {
    return items.fold(0, (sum, item) => sum + (item.priceAtTime * item.quantity));
  }
}
