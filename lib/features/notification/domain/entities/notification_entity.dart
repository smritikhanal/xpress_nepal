class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final String
  type; // 'order_status', 'order_shipped', 'order_delivered', 'general'
  final String? orderId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.orderId,
    required this.isRead,
    required this.createdAt,
  });
}
