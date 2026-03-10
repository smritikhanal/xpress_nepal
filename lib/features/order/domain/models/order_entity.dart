class OrderEntity {
  final String id;
  final String userId; // User ID who placed the order
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final ShippingAddressEntity shippingAddress;
  final DateTime createdAt;

  // Optional/Advanced fields
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.shippingAddress,
    required this.createdAt,
    this.deliveryDate,
    this.deliveryTimeSlot,
  });

  OrderEntity copyWith({
    String? id,
    String? userId,
    List<OrderItemEntity>? items,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    ShippingAddressEntity? shippingAddress,
    DateTime? createdAt,
    DateTime? deliveryDate,
    String? deliveryTimeSlot,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
    );
  }
}

class OrderItemEntity {
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final Map<String, dynamic> attributes;
  final String? image;

  OrderItemEntity({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    this.attributes = const {},
    this.image,
  });
}

class ShippingAddressEntity {
  final String fullName;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String street;
  final String postalCode;

  ShippingAddressEntity({
    required this.fullName,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.street,
    this.postalCode = '',
  });
}
