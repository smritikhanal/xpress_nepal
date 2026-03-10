import '../../domain/models/cart_item.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required super.productId,
    required super.quantity,
    required super.priceAtTime,
    super.productName,
    super.productImage,
    super.selectedAttributes,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // productId is populated by backend so it's a Map, but we handle String case just in case
    final productInfo = json['productId'];
    String pId = '';
    String? pName;
    String? pImage;

    if (productInfo is Map) {
      pId = productInfo['_id'] ?? '';
      pName = productInfo['title'];
      if (productInfo['images'] is List &&
          (productInfo['images'] as List).isNotEmpty) {
        pImage = productInfo['images'][0];
      }
    } else if (productInfo is String) {
      pId = productInfo;
    }

    // Parse attributes
    Map<String, dynamic>? parsedAttributes;
    if (json['attributes'] != null && json['attributes'] is Map) {
      parsedAttributes = Map<String, dynamic>.from(json['attributes']);
    } else if (json['selectedAttributes'] != null &&
        json['selectedAttributes'] is Map) {
      parsedAttributes = Map<String, dynamic>.from(json['selectedAttributes']);
    }

    return CartItemModel(
      productId: pId,
      quantity: json['quantity'] ?? 0,
      priceAtTime: (json['priceAtTime'] as num?)?.toDouble() ?? 0.0,
      productName: pName,
      productImage: pImage,
      selectedAttributes: parsedAttributes,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'priceAtTime': priceAtTime,
  };
}
