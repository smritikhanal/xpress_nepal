import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/messages/domain/entities/message_entity.dart';
import 'package:xpress_nepal/features/messages/presentation/pages/message_chat_page.dart';
import 'package:xpress_nepal/features/messages/presentation/providers/message_provider.dart';
import 'package:xpress_nepal/features/messages/presentation/view_model/message_view_model.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _viewModel = MessageProvider.instance.viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data only once after the first build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _viewModel.inbox.isEmpty &&
          _viewModel.sentMessages.isEmpty) {
        _viewModel.loadInbox();
        _viewModel.loadSentMessages();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthProvider.instance.authViewModel.state.user;
    final isSeller = currentUser?.role == 'seller';
    final primaryColor = isSeller ? AppColors.sellerPrimary : AppColors.primary;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                return Consumer<MessageViewModel>(
                  builder: (context, vm, _) {
                    // Show mark all as read button only on inbox tab and when there are unread messages
                    if (_tabController.index == 0 && vm.unreadCount > 0) {
                      return IconButton(
                        onPressed: () async {
                          await vm.markAllAsRead();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All messages marked as read'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.done_all),
                        tooltip: 'Mark all as read',
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Inbox'),
                    const SizedBox(width: 8),
                    Consumer<MessageViewModel>(
                      builder: (context, vm, _) {
                        if (vm.unreadCount > 0) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              vm.unreadCount > 99 ? '99+' : '${vm.unreadCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const Tab(text: 'Sent'),
            ],
          ),
        ),
        backgroundColor: AppColors.background,
        body: TabBarView(
          controller: _tabController,
          children: [_buildInboxTab(), _buildSentTab()],
        ),
      ),
    );
  }

  /// Build grouped conversation list from inbox messages
  List<_ConversationData> _buildConversations(List<MessageEntity> inbox) {
    final Map<String, List<MessageEntity>> grouped = {};
    for (final msg in inbox) {
      grouped.putIfAbsent(msg.senderId, () => []).add(msg);
    }
    final conversations = grouped.entries.map((e) {
      final msgs = List<MessageEntity>.from(e.value)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final sender = msgs.first.sender;
      // Find product from ANY message in the conversation (not just the latest)
      final product = msgs
          .map((m) => m.product)
          .firstWhere((p) => p != null, orElse: () => null);
      return _ConversationData(
        contactId: e.key,
        contactName: sender?.shopName ?? sender?.name ?? 'Unknown',
        contactEmail: sender?.email ?? '',
        lastMessage: msgs.first,
        unreadCount: msgs.where((m) => !m.isRead).length,
        product: product,
      );
    }).toList();
    conversations.sort(
      (a, b) => b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt),
    );
    return conversations;
  }

  Widget _buildInboxTab() {
    return Consumer<MessageViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.inbox.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null && vm.inbox.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vm.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.loadInbox(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final conversations = _buildConversations(vm.inbox);

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.textHint.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No messages yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final currentUser = AuthProvider.instance.authViewModel.state.user;
        final isSeller = currentUser?.role == 'seller';
        final primaryColor = isSeller
            ? AppColors.sellerPrimary
            : AppColors.primary;

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            await vm.loadInbox();
            await vm.loadSentMessages();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return _ConversationCard(
                conversation: conv,
                primaryColor: primaryColor,
                onTap: () => _openConversation(conv),
                onDelete: () {
                  // delete all messages from this sender
                  for (final msg
                      in vm.inbox
                          .where((m) => m.senderId == conv.contactId)
                          .toList()) {
                    vm.deleteMessage(msg.id, fromInbox: true);
                  }
                },
                onProductTap: conv.product != null
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerProductDetailScreen(
                            productId: conv.product!.id,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSentTab() {
    return Consumer<MessageViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.sentMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Group sent messages by receiver
        final Map<String, List<MessageEntity>> grouped = {};
        for (final msg in vm.sentMessages) {
          grouped.putIfAbsent(msg.receiverId, () => []).add(msg);
        }
        final conversations = grouped.entries.map((e) {
          final msgs = List<MessageEntity>.from(e.value)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final receiver = msgs.first.receiver;
          // Find product from ANY message in the conversation
          final product = msgs
              .map((m) => m.product)
              .firstWhere((p) => p != null, orElse: () => null);
          return _ConversationData(
            contactId: e.key,
            contactName: receiver?.shopName ?? receiver?.name ?? 'Unknown',
            contactEmail: receiver?.email ?? '',
            lastMessage: msgs.first,
            unreadCount: 0,
            product: product,
          );
        }).toList();
        conversations.sort(
          (a, b) => b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt),
        );

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_outlined,
                  size: 64,
                  color: AppColors.textHint.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No sent messages',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final currentUser = AuthProvider.instance.authViewModel.state.user;
        final isSeller = currentUser?.role == 'seller';
        final primaryColor = isSeller
            ? AppColors.sellerPrimary
            : AppColors.primary;

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            await vm.loadSentMessages();
            await vm.loadInbox();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return _ConversationCard(
                conversation: conv,
                primaryColor: primaryColor,
                onTap: () => _openConversation(conv),
                onDelete: () {
                  for (final msg
                      in vm.sentMessages
                          .where((m) => m.receiverId == conv.contactId)
                          .toList()) {
                    vm.deleteMessage(msg.id, fromInbox: false);
                  }
                },
                onProductTap: conv.product != null
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerProductDetailScreen(
                            productId: conv.product!.id,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _openConversation(_ConversationData conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageChatPage(
          contactId: conv.contactId,
          contactName: conv.contactName,
          contactEmail: conv.contactEmail,
          initialSubject: conv.lastMessage.subject,
        ),
      ),
    ).then((_) {
      // Refresh after returning from chat to update unread counts
      // Use microtask to avoid setState during build
      Future.microtask(() {
        _viewModel.loadInbox();
        _viewModel.loadSentMessages();
      });
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class for a grouped conversation
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationData {
  final String contactId;
  final String contactName;
  final String contactEmail;
  final MessageEntity lastMessage;
  final int unreadCount;
  final MessageProduct? product;

  const _ConversationData({
    required this.contactId,
    required this.contactName,
    required this.contactEmail,
    required this.lastMessage,
    required this.unreadCount,
    this.product,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversation card widget
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationCard extends StatelessWidget {
  final _ConversationData conversation;
  final Color primaryColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onProductTap;

  const _ConversationCard({
    required this.conversation,
    required this.primaryColor,
    required this.onTap,
    required this.onDelete,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final last = conversation.lastMessage;

    return Dismissible(
      key: Key('conv_${conversation.contactId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: hasUnread ? primaryColor.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasUnread
                  ? primaryColor.withOpacity(0.25)
                  : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor.withOpacity(0.12),
                    child: Text(
                      conversation.contactName[0].toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          conversation.unreadCount > 9
                              ? '9+'
                              : '${conversation.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conversation.contactName,
                            style: TextStyle(
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDate(last.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread
                                ? primaryColor
                                : AppColors.textHint,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Subject line
                    Text(
                      last.subject,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Last message preview
                    Text(
                      last.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasUnread
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Product tag if any
                    if (conversation.product != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (onProductTap != null) {
                            onProductTap!();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  conversation.product!.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: primaryColor.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
