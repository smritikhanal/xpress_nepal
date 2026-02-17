import '../../domain/models/order_entity.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.totalAmount,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.orderStatus,
    required super.shippingAddress,
    required super.createdAt,
    super.deliveryDate,
    super.deliveryTimeSlot,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map
          ? json['userId']['_id']
          : (json['userId'] ?? ''),
      items:
          (json['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash_on_delivery',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      orderStatus: json['orderStatus'] ?? 'placed',
      shippingAddress: ShippingAddressModel.fromJson(
        json['shippingAddress'] ?? {},
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      deliveryTimeSlot: json['deliveryTimeSlot'],
    );
  }
}

class OrderItemModel extends OrderItemEntity {
  OrderItemModel({
    required super.productId,
    required super.title,
    required super.quantity,
    required super.price,
    super.attributes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Handle populated product if necessary, though backend sends flattened items usually
    // Based on controller: push({ productId: product._id, title... })

    // Robust attributes parsing
    // print('DEBUG: Item JSON: $json'); // UNCOMMENT TO DEBUG
    Map<String, dynamic> parsedAttributes = {};
    var rawAttrs =
        json['attributes'] ?? json['selectedAttributes'] ?? json['options'];

    if (rawAttrs is Map) {
      parsedAttributes = Map<String, dynamic>.from(rawAttrs);
    } else if (rawAttrs is List) {
      // Handle list format if applicable, e.g. [{ "key": "Color", "value": "Red" }] or similar
      for (var item in rawAttrs) {
        if (item is Map) {
          // Try common key-value patterns
          var key = item['key'] ?? item['name'] ?? item['label'];
          var value = item['value'] ?? item['option'];
          if (key != null && value != null) {
            parsedAttributes[key.toString()] = value;
          }
        }
      }
    }

    return OrderItemModel(
      productId: json['productId'] is Map
          ? json['productId']['_id']
          : (json['productId'] ?? ''),
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      attributes: parsedAttributes,
    );
  }
}

class ShippingAddressModel extends ShippingAddressEntity {
  ShippingAddressModel({
    required super.fullName,
    required super.phone,
    required super.country,
    required super.state,
    required super.city,
    required super.street,
    super.postalCode,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }
}
