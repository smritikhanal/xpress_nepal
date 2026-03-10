import '../../domain/models/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<OrderEntity> createOrder({
    required String shippingAddressId,
    required String paymentMethod,
    DateTime? deliveryDate,
    String? deliveryTimeSlot,
    List<String>? selectedProductIds,
  }) async {
    final data = {
      'shippingAddressId': shippingAddressId,
      'paymentMethod': paymentMethod,
      if (deliveryDate != null) 'deliveryDate': deliveryDate.toIso8601String(),
      if (deliveryTimeSlot != null) 'deliveryTimeSlot': deliveryTimeSlot,
      if (selectedProductIds != null && selectedProductIds.isNotEmpty)
        'selectedProductIds': selectedProductIds,
    };
    return await remoteDataSource.createOrder(data);
  }

  @override
  Future<List<OrderEntity>> getMyOrders({int page = 1, int limit = 10}) async {
    return await remoteDataSource.getMyOrders(page, limit);
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    return await remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<List<OrderEntity>> getSellerOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.getSellerOrders(page, limit);
  }

  @override
  Future<OrderEntity> updateOrderStatus(String orderId, String status) async {
    return await remoteDataSource.updateOrderStatus(orderId, status);
  }

  @override
  Future<OrderEntity> updatePaymentStatus(
    String orderId,
    String paymentStatus,
  ) async {
    return await remoteDataSource.updatePaymentStatus(orderId, paymentStatus);
  }
}
