import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/messages/domain/entities/message_entity.dart';
import 'package:xpress_nepal/features/messages/presentation/providers/message_provider.dart';
import 'package:xpress_nepal/features/messages/presentation/view_model/message_view_model.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';

class MessageChatPage extends StatefulWidget {
  final String contactId;
  final String contactName;
  final String contactEmail;
  final String? initialSubject; // subject context (e.g. product inquiry)

  const MessageChatPage({
    super.key,
    required this.contactId,
    required this.contactName,
    required this.contactEmail,
    this.initialSubject,
  });

  @override
  State<MessageChatPage> createState() => _MessageChatPageState();
}

class _MessageChatPageState extends State<MessageChatPage> {
  final _viewModel = MessageProvider.instance.viewModel;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markUnreadAsRead();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markUnreadAsRead() {
    for (final msg in _viewModel.inbox) {
      if (msg.senderId == widget.contactId && !msg.isRead) {
        _viewModel.markAsRead(msg.id);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<MessageEntity> _getConversationMessages() {
    final inbox = _viewModel.inbox
        .where((m) => m.senderId == widget.contactId)
        .toList();
    final sent = _viewModel.sentMessages
        .where((m) => m.receiverId == widget.contactId)
        .toList();
    final all = [...inbox, ...sent];
    all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return all;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messages = _getConversationMessages();
    String subject;
    if (widget.initialSubject != null) {
      subject = widget.initialSubject!.startsWith('Re:')
          ? widget.initialSubject!
          : 'Re: ${widget.initialSubject}';
    } else if (messages.isNotEmpty) {
      final first = messages.first.subject;
      subject = first.startsWith('Re:') ? first : 'Re: $first';
    } else {
      subject = 'Message';
    }

    setState(() => _sending = true);
    _messageController.clear();

    final success = await _viewModel.sendMessage(
      receiverId: widget.contactId,
      subject: subject,
      message: text,
    );

    if (mounted) {
      setState(() => _sending = false);
      if (success) {
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthProvider.instance.authViewModel.state.user;
    final isSeller = currentUser?.role == 'seller';
    final primaryColor = isSeller ? AppColors.sellerPrimary : AppColors.primary;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFECEFF1),
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 1,
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  widget.contactName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contactName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.contactEmail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Consumer<MessageViewModel>(
          builder: (context, vm, _) {
            final messages = _getConversationMessages();
            if (messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: AppColors.textHint.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No messages yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == currentUser?.id;
                final showDate =
                    index == 0 ||
                    !_isSameDay(messages[index - 1].createdAt, msg.createdAt);
                return Column(
                  children: [
                    if (showDate) _buildDateDivider(msg.createdAt),
                    _buildBubble(msg, isMe, primaryColor),
                  ],
                );
              },
            );
          },
        ),
        bottomNavigationBar: _buildInputBar(primaryColor),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _formatDateLabel(date),
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildBubble(MessageEntity msg, bool isMe, Color primaryColor) {
    final bubbleColor = isMe ? primaryColor : Colors.white;
    final textColor = isMe ? Colors.white : AppColors.textPrimary;
    final timeColor = isMe ? Colors.white70 : AppColors.textHint;
    final crossAxis = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: primaryColor.withOpacity(0.15),
              child: Text(
                widget.contactName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: crossAxis,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: crossAxis,
                    children: [
                      if (msg.product != null) ...[
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerProductDetailScreen(
                                productId: msg.product!.id,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.white.withOpacity(0.2)
                                  : primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 11,
                                  color: isMe ? Colors.white70 : primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    msg.product!.title,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white70
                                          : primaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      Text(
                        msg.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(msg.createdAt),
                  style: TextStyle(fontSize: 10, color: timeColor),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _sending ? primaryColor.withOpacity(0.6) : primaryColor,
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);
    if (msgDay == today) return 'Today';
    if (msgDay == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }
}
