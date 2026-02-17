class CartItem {
  final String productId;
  final int quantity;
  final double priceAtTime;

  // Optional UI-only fields (NOT required by backend)
  final String? productName;
  final String? productImage;

  // Stores selected attributes like {'size': 'M', 'color': 'Red'}
  final Map<String, dynamic>? selectedAttributes;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.priceAtTime,
    this.productName,
    this.productImage,
    this.selectedAttributes,
  });

  CartItem copyWith({
    int? quantity,
    Map<String, dynamic>? selectedAttributes,
  }) {
    return CartItem(
      productId: productId,
      quantity: quantity ?? this.quantity,
      priceAtTime: priceAtTime,
      productName: productName,
      productImage: productImage,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
    );
  }
}
