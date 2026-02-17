import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/messages/data/models/message_model.dart';
import 'package:xpress_nepal/features/messages/domain/entities/message_entity.dart';
import 'package:xpress_nepal/features/messages/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final ApiService _apiService;

  MessageRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<MessageEntity>> getInbox({bool? isRead}) async {
    final response = await _apiService.get(
      ApiConstants.messageInbox,
      queryParams: isRead != null ? {'isRead': isRead.toString()} : null,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final actualData = data['data'] ?? data;
      final messagesList = ((actualData['messages'] as List?) ?? [])
          .map((e) => MessageModel.fromJson(e))
          .toList();
      return messagesList;
    } else {
      throw ApiException(response.message ?? 'Failed to fetch inbox');
    }
  }

  @override
  Future<List<MessageEntity>> getSentMessages() async {
    final response = await _apiService.get(
      ApiConstants.messageSent,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final actualData = data['data'] ?? data;
      final messagesList = (actualData is List ? actualData : [])
          .map((e) => MessageModel.fromJson(e))
          .toList();
      return messagesList;
    } else {
      throw ApiException(response.message ?? 'Failed to fetch sent messages');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiService.get(
      ApiConstants.messageUnreadCount,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final actualData = data['data'] ?? data;
      return actualData['count'] as int? ?? 0;
    } else {
      throw ApiException(response.message ?? 'Failed to fetch unread count');
    }
  }

  @override
  Future<MessageEntity> sendMessage({
    required String receiverId,
    String? productId,
    required String subject,
    required String message,
  }) async {
    final response = await _apiService.post(
      ApiConstants.messages,
      body: {
        'receiverId': receiverId,
        if (productId != null) 'productId': productId,
        'subject': subject,
        'message': message,
      },
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final actualData = data['data'] ?? data;
      return MessageModel.fromJson(actualData);
    } else {
      throw ApiException(response.message ?? 'Failed to send message');
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    final response = await _apiService.put(
      ApiConstants.markMessageRead(messageId),
      requiresAuth: true,
    );

    if (!response.success) {
      throw ApiException(response.message ?? 'Failed to mark as read');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final response = await _apiService.delete(
      ApiConstants.deleteMessage(messageId),
      requiresAuth: true,
    );

    if (!response.success) {
      throw ApiException(response.message ?? 'Failed to delete message');
    }
  }
}
