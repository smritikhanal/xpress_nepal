import 'package:flutter/material.dart';
import 'package:xpress_nepal/features/messages/domain/entities/message_entity.dart';
import 'package:xpress_nepal/features/messages/domain/repositories/message_repository.dart';

class MessageViewModel extends ChangeNotifier {
  final MessageRepository _repository;

  List<MessageEntity> _inbox = [];
  List<MessageEntity> _sentMessages = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<MessageEntity> get inbox => _inbox;
  List<MessageEntity> get sentMessages => _sentMessages;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MessageViewModel({required MessageRepository repository})
    : _repository = repository;

  Future<void> loadInbox({bool? isRead}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Preserve locally-marked-as-read IDs to avoid race condition with backend
    final locallyReadIds = _inbox
        .where((m) => m.isRead)
        .map((m) => m.id)
        .toSet();

    try {
      final freshInbox = await _repository.getInbox(isRead: isRead);
      // Apply local read state: if we already marked a message as read locally,
      // keep it as read even if the backend hasn't processed it yet
      _inbox = freshInbox.map((m) {
        if (!m.isRead && locallyReadIds.contains(m.id)) {
          return MessageEntity(
            id: m.id,
            senderId: m.senderId,
            receiverId: m.receiverId,
            productId: m.productId,
            subject: m.subject,
            message: m.message,
            isRead: true,
            createdAt: m.createdAt,
            updatedAt: m.updatedAt,
            sender: m.sender,
            receiver: m.receiver,
            product: m.product,
          );
        }
        return m;
      }).toList();
      // Compute count from the merged local state — no separate API call needed
      _unreadCount = _inbox.where((m) => !m.isRead).length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSentMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sentMessages = await _repository.getSentMessages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
    } catch (e) {
      // Silently fail for unread count
    }
  }

  // Public method to load unread count
  Future<void> loadUnreadCount() async {
    await _loadUnreadCount();
    notifyListeners();
  }

  Future<bool> sendMessage({
    required String receiverId,
    String? productId,
    required String subject,
    required String message,
  }) async {
    try {
      await _repository.sendMessage(
        receiverId: receiverId,
        productId: productId,
        subject: subject,
        message: message,
      );
      await loadSentMessages();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(String messageId) async {
    // Optimistic update: immediately mark as read in local state
    final index = _inbox.indexWhere((m) => m.id == messageId);
    if (index != -1 && !_inbox[index].isRead) {
      _inbox[index] = MessageEntity(
        id: _inbox[index].id,
        senderId: _inbox[index].senderId,
        receiverId: _inbox[index].receiverId,
        productId: _inbox[index].productId,
        subject: _inbox[index].subject,
        message: _inbox[index].message,
        isRead: true,
        createdAt: _inbox[index].createdAt,
        updatedAt: _inbox[index].updatedAt,
        sender: _inbox[index].sender,
        receiver: _inbox[index].receiver,
        product: _inbox[index].product,
      );
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      notifyListeners();
    }
    // Sync with backend (fire and forget — local state is already updated)
    try {
      await _repository.markAsRead(messageId);
    } catch (e) {
      print('Error syncing markAsRead to server: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      // Update local state - mark all inbox messages as read
      _inbox = _inbox.map((message) {
        if (!message.isRead) {
          return MessageEntity(
            id: message.id,
            senderId: message.senderId,
            receiverId: message.receiverId,
            productId: message.productId,
            subject: message.subject,
            message: message.message,
            isRead: true,
            createdAt: message.createdAt,
            updatedAt: message.updatedAt,
            sender: message.sender,
            receiver: message.receiver,
            product: message.product,
          );
        }
        return message;
      }).toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId, {bool fromInbox = true}) async {
    try {
      await _repository.deleteMessage(messageId);

      if (fromInbox) {
        final message = _inbox.firstWhere((m) => m.id == messageId);
        _inbox.removeWhere((m) => m.id == messageId);
        if (!message.isRead) {
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        }
      } else {
        _sentMessages.removeWhere((m) => m.id == messageId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
