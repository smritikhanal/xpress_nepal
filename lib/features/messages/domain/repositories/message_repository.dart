import 'package:xpress_nepal/features/messages/domain/entities/message_entity.dart';

abstract class MessageRepository {
  Future<List<MessageEntity>> getInbox({bool? isRead});
  Future<List<MessageEntity>> getSentMessages();
  Future<int> getUnreadCount();
  Future<MessageEntity> sendMessage({
    required String receiverId,
    String? productId,
    required String subject,
    required String message,
  });
  Future<void> markAsRead(String messageId);
  Future<void> deleteMessage(String messageId);
}
