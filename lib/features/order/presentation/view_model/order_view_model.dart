import 'package:flutter/foundation.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/models/order_entity.dart';
import '../state/order_state.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repo;

  OrderState _state = OrderState.initial();
  OrderState get state => _state;

  OrderViewModel({required OrderRepository repo}) : _repo = repo;

  Future<void> createOrder({
    required String shippingAddressId,
    required String paymentMethod,
    DateTime? deliveryDate,
    String? deliveryTimeSlot,
    required VoidCallback onSuccess,
  }) async {
    _state = _state.copyWith(status: OrderStatus.loading);
    notifyListeners();

    try {
      await _repo.createOrder(
        shippingAddressId: shippingAddressId,
        paymentMethod: paymentMethod,
        deliveryDate: deliveryDate,
        deliveryTimeSlot: deliveryTimeSlot,
      );
      _state = _state.copyWith(status: OrderStatus.loaded);
      onSuccess();
    } catch (e) {
      _state = _state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> getMyOrders({bool refresh = false}) async {
    _state = _state.copyWith(status: OrderStatus.loading);
    notifyListeners();

    try {
      final orders = await _repo.getMyOrders();
      _state = _state.copyWith(
        status: OrderStatus.loaded,
        orders: orders,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> getOrderById(String orderId) async {
    _state = _state.copyWith(status: OrderStatus.loading);
    notifyListeners();

    try {
      final order = await _repo.getOrderById(orderId);
      _state = _state.copyWith(
        status: OrderStatus.loaded,
        selectedOrder: order,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }

  // Seller Methods
  Future<void> getSellerOrders({bool refresh = false}) async {
    _state = _state.copyWith(status: OrderStatus.loading);
    notifyListeners();

    try {
      final orders = await _repo.getSellerOrders();
      _state = _state.copyWith(
        status: OrderStatus.loaded,
        sellerOrders: orders,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _state = _state.copyWith(status: OrderStatus.loading);
    notifyListeners();

    try {
      final updatedOrder = await _repo.updateOrderStatus(orderId, status);
      
      // Update local seller list
      final updatedList = _state.sellerOrders.map((order) {
        return order.id == orderId ? updatedOrder : order;
      }).toList().cast<OrderEntity>();

      _state = _state.copyWith(
        status: OrderStatus.loaded,
        sellerOrders: updatedList,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }
}
