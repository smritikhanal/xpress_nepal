import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/messages/domain/entities/message_entity.dart';
import 'package:xpress_nepal/features/messages/presentation/pages/message_detail_page.dart';
import 'package:xpress_nepal/features/messages/presentation/providers/message_provider.dart';
import 'package:xpress_nepal/features/messages/presentation/view_model/message_view_model.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadInbox();
      _viewModel.loadSentMessages();
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

        if (vm.inbox.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: () => vm.loadInbox(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.inbox.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final message = vm.inbox[index];
              final currentUser =
                  AuthProvider.instance.authViewModel.state.user;
              final isSeller = currentUser?.role == 'seller';
              final primaryColor = isSeller
                  ? AppColors.sellerPrimary
                  : AppColors.primary;
              return _MessageCard(
                message: message,
                isInbox: true,
                onTap: () => _openMessage(message, true),
                onDelete: () => vm.deleteMessage(message.id, fromInbox: true),
                primaryColor: primaryColor,
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

        if (vm.sentMessages.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: () => vm.loadSentMessages(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.sentMessages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final message = vm.sentMessages[index];
              final currentUser =
                  AuthProvider.instance.authViewModel.state.user;
              final isSeller = currentUser?.role == 'seller';
              final primaryColor = isSeller
                  ? AppColors.sellerPrimary
                  : AppColors.primary;
              return _MessageCard(
                message: message,
                isInbox: false,
                onTap: () => _openMessage(message, false),
                onDelete: () => vm.deleteMessage(message.id, fromInbox: false),
                primaryColor: primaryColor,
              );
            },
          ),
        );
      },
    );
  }

  void _openMessage(MessageEntity message, bool isInbox) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MessageDetailPage(message: message, isInbox: isInbox),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final MessageEntity message;
  final bool isInbox;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Color primaryColor;

  const _MessageCard({
    required this.message,
    required this.isInbox,
    required this.onTap,
    required this.onDelete,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final otherPerson =
        (isInbox ? message.sender : message.receiver) as dynamic;
    final displayName = otherPerson?.shopName ?? otherPerson?.name ?? 'Unknown';

    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isInbox && !message.isRead
                ? primaryColor.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isInbox && !message.isRead
                  ? primaryColor.withOpacity(0.3)
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      displayName[0].toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontWeight: isInbox && !message.isRead
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isInbox && !message.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          _formatDate(message.createdAt),
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.subject,
                style: TextStyle(
                  fontWeight: isInbox && !message.isRead
                      ? FontWeight.bold
                      : FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                message.message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (message.product != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          message.product!.title,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
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
