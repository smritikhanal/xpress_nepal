import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/home/presentation/providers/home_content_provider.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class TopSellersSection extends StatelessWidget {
  const TopSellersSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSellers = context.watch<HomeContentProvider>().topSellers;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final listHeight = isTablet ? 160.0 : 140.0;

    return Column(
      children: [
        SectionHeader(
          title: 'Top Sellers',
          subtitle: 'Trusted stores for you',
          icon: Icons.store_rounded,
          onViewAll: () {},
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: topSellers.length,
            itemBuilder: (context, index) {
              return _buildSellerCard(topSellers[index], isTablet: isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSellerCard(
    Map<String, dynamic> seller, {
    required bool isTablet,
  }) {
    final cardWidth = isTablet ? 160.0 : 140.0;
    final avatarSize = isTablet ? 60.0 : 50.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Seller Avatar
          Stack(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.store_rounded,
                    color: Colors.white,
                    size: isTablet ? 28 : 24,
                  ),
                ),
              ),
              if (seller['verified'])
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: AppColors.primary,
                      size: isTablet ? 18 : 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            seller['name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.highlight,
              ),
              const SizedBox(width: 4),
              Text(
                '${seller['rating']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                ' • ${seller['products']} items',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
