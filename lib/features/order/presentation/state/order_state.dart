import '../../domain/models/order_entity.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderState {
  final OrderStatus status;
  final List<OrderEntity> orders;
  final List<OrderEntity> sellerOrders;
  final OrderEntity? selectedOrder;
  final String? errorMessage;
  final bool hasReachedMax;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.sellerOrders = const [],
    this.selectedOrder,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  factory OrderState.initial() => const OrderState();

  OrderState copyWith({
    OrderStatus? status,
    List<OrderEntity>? orders,
    List<OrderEntity>? sellerOrders,
    OrderEntity? selectedOrder,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      sellerOrders: sellerOrders ?? this.sellerOrders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: errorMessage, // Reset error on state change typically, but here passing explicitly
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
