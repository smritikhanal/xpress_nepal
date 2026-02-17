import 'package:xpress_nepal/features/messages/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    super.productId,
    required super.subject,
    required super.message,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
    super.sender,
    super.receiver,
    super.product,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id']?.toString() ?? '',
      senderId: json['senderId'] is Map
          ? json['senderId']['_id']?.toString() ?? ''
          : json['senderId']?.toString() ?? '',
      receiverId: json['receiverId'] is Map
          ? json['receiverId']['_id']?.toString() ?? ''
          : json['receiverId']?.toString() ?? '',
      productId: json['productId'] is Map
          ? json['productId']['_id']?.toString()
          : json['productId']?.toString(),
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sender: json['senderId'] is Map
          ? MessageSender(
              id: json['senderId']['_id']?.toString() ?? '',
              name: json['senderId']['name']?.toString() ?? '',
              email: json['senderId']['email']?.toString() ?? '',
              shopName: json['senderId']['shopName']?.toString(),
            )
          : null,
      receiver: json['receiverId'] is Map
          ? MessageReceiver(
              id: json['receiverId']['_id']?.toString() ?? '',
              name: json['receiverId']['name']?.toString() ?? '',
              email: json['receiverId']['email']?.toString() ?? '',
              shopName: json['receiverId']['shopName']?.toString(),
            )
          : null,
      product: json['productId'] is Map
          ? MessageProduct(
              id: json['productId']['_id']?.toString() ?? '',
              title: json['productId']['title']?.toString() ?? '',
              slug: json['productId']['slug']?.toString() ?? '',
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'productId': productId,
      'subject': subject,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
