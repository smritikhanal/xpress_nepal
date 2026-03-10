import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String? productId;
  final String subject;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageSender? sender;
  final MessageReceiver? receiver;
  final MessageProduct? product;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.productId,
    required this.subject,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.product,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    receiverId,
    productId,
    subject,
    message,
    isRead,
    createdAt,
    updatedAt,
  ];
}

class MessageSender extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? shopName;

  const MessageSender({
    required this.id,
    required this.name,
    required this.email,
    this.shopName,
  });

  @override
  List<Object?> get props => [id, name, email, shopName];
}

class MessageReceiver extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? shopName;

  const MessageReceiver({
    required this.id,
    required this.name,
    required this.email,
    this.shopName,
  });

  @override
  List<Object?> get props => [id, name, email, shopName];
}

class MessageProduct extends Equatable {
  final String id;
  final String title;
  final String slug;

  const MessageProduct({
    required this.id,
    required this.title,
    required this.slug,
  });

  @override
  List<Object?> get props => [id, title, slug];
}
