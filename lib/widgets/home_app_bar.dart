import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController = TextEditingController();
  final VoidCallback? onLogout;

  HomeAppBar({super.key, this.onLogout});

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
              // Logo and title
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.textLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Xpress Nepal',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w800,
                      fontSize: isTablet ? 22 : 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              SizedBox(width: isTablet ? 24 : 12),

              // Search bar
              Expanded(
                child: Container(
                  height: 44,
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
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: AppColors.textHint,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 46,
                        minHeight: 44,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Action buttons
              _buildActionButton(
                icon: Icons.notifications_rounded,
                onPressed: () {},
                isTablet: isTablet,
                badge: 3,
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_rounded,
                onPressed: () {},
                isTablet: isTablet,
              ),
              if (onLogout != null)
                _buildActionButton(
                  icon: Icons.logout_rounded,
                  onPressed: onLogout!,
                  isTablet: isTablet,
                  tooltip: 'Logout',
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
