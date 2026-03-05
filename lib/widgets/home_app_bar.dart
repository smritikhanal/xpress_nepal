import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/notification/presentation/pages/notification_page.dart';
import 'package:xpress_nepal/features/notification/presentation/providers/notification_provider.dart';
import 'package:xpress_nepal/features/messages/presentation/pages/messages_page.dart';
import 'package:xpress_nepal/features/messages/presentation/providers/message_provider.dart';
import 'package:xpress_nepal/features/home/presentation/pages/wishlist_screen.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onSearchTap;

  const HomeAppBar({super.key, this.onLogout, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 650;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Logo
              Container(
                height: isTablet ? 45 : 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/logo/logo.png',
                  height: isTablet ? 37 : 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.primary,
                      size: isTablet ? 28 : 24,
                    );
                  },
                ),
              ),
              if (isTablet) ...[
                const SizedBox(width: 24),

                // Search bar - only on tablet (tappable to open search)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (onSearchTap != null) {
                        onSearchTap!();
                      }
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Search products...',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ListenableBuilder(
                    listenable: AuthProvider.instance.authViewModel,
                    builder: (context, _) {
                      final user =
                          AuthProvider.instance.authViewModel.state.user;
                      final firstName = user?.name.split(' ').first ?? 'there';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hello, $firstName! 👋',
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'What are you looking for?',
                            style: TextStyle(
                              color: AppColors.textLight.withValues(
                                alpha: 0.75,
                              ),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(width: 8),

              // Search icon for mobile only
              if (!isTablet)
                Container(
                  key: const ValueKey('search_button'),
                  child: _buildActionButton(
                    icon: Icons.search_rounded,
                    onPressed: () {
                      if (onSearchTap != null) {
                        onSearchTap!();
                      }
                    },
                    isTablet: isTablet,
                  ),
                ),

              // Action buttons
              Container(
                key: const ValueKey('notification_button'),
                child: ListenableBuilder(
                  listenable:
                      NotificationProvider.instance.notificationViewModel,
                  builder: (context, _) {
                    final vm =
                        NotificationProvider.instance.notificationViewModel;
                    final unreadCount = vm.state.unreadCount;

                    return _buildActionButton(
                      icon: Icons.notifications_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                      isTablet: isTablet,
                      badge: unreadCount > 0 ? unreadCount : null,
                    );
                  },
                ),
              ),
              // Messages button with unread count
              Container(
                key: const ValueKey('messages_button'),
                child: ListenableBuilder(
                  listenable: MessageProvider.instance.viewModel,
                  builder: (context, _) {
                    final vm = MessageProvider.instance.viewModel;
                    final unreadCount = vm.unreadCount;

                    return _buildActionButton(
                      icon: Icons.chat_bubble_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MessagesPage(),
                          ),
                        );
                      },
                      isTablet: isTablet,
                      badge: unreadCount > 0 ? unreadCount : null,
                    );
                  },
                ),
              ),
              // Wishlist button
              Container(
                key: const ValueKey('wishlist_button'),
                child: Consumer<WishlistProvider>(
                  builder: (context, wishlistProvider, _) {
                    final count = wishlistProvider.wishlist.length;
                    return _buildActionButton(
                      icon: Icons.favorite_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistScreen(),
                          ),
                        );
                      },
                      isTablet: isTablet,
                      badge: count > 0 ? count : null,
                      tooltip: 'Wishlist',
                    );
                  },
                ),
              ),
              if (onLogout != null)
                Container(
                  key: const ValueKey('logout_button'),
                  child: _buildActionButton(
                    icon: Icons.logout_rounded,
                    onPressed: onLogout!,
                    isTablet: isTablet,
                    tooltip: 'Logout',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isTablet,
    String? tooltip,
    int? badge,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: isTablet ? 24 : 20,
              color: AppColors.textLight,
            ),
          ),
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: isTablet ? 44 : 40,
            minHeight: isTablet ? 44 : 40,
          ),
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.highlight,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
