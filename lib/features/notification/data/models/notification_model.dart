import 'package:xpress_nepal/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required String id,
    required String title,
    required String message,
    required String type,
    String? orderId,
    required bool isRead,
    required DateTime createdAt,
  }) : super(
         id: id,
         title: title,
         message: message,
         type: type,
         orderId: orderId,
         isRead: isRead,
         createdAt: createdAt,
       );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      orderId: json['orderId']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'type': type,
      'orderId': orderId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
