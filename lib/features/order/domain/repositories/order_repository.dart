import '../models/order_entity.dart';

abstract class OrderRepository {
  /// Create a new order
  Future<OrderEntity> createOrder({
    required String shippingAddressId,
    required String paymentMethod,
    DateTime? deliveryDate,
    String? deliveryTimeSlot,
  });

  /// Get current user's order history
  Future<List<OrderEntity>> getMyOrders({int page = 1, int limit = 10});

  /// Get specific order details
  Future<OrderEntity> getOrderById(String orderId);

  /// Get orders for seller (containing their products)
  Future<List<OrderEntity>> getSellerOrders({int page = 1, int limit = 10});

  /// Update order status (Seller/Admin only)
  Future<OrderEntity> updateOrderStatus(String orderId, String status);
}
