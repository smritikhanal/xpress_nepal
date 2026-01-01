import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_colors.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class TrendingProductsSection extends StatelessWidget {
  const TrendingProductsSection({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> _trendingProducts = [
    {
      'name': 'iPhone 15 Pro Max',
      'price': 190000,
      'rating': 4.8,
      'reviews': 2341,
      'image': 'assets/images/products/iphone.jpg',
      'isNew': true,
    },
    {
      'name': 'Samsung Galaxy S24',
      'price': 85550,
      'rating': 4.6,
      'reviews': 892,
      'image': 'assets/images/products/samsung.jpg',
      'isNew': false,
    },
    {
      'name': 'Winter Jacket Premium',
      'price': 1520,
      'rating': 4.9,
      'reviews': 1567,
      'image': 'assets/images/products/winterjacket.jpg',
      'isNew': true,
    },
    {
      'name': 'Leather Boots',
      'price': 3500,
      'rating': 4.7,
      'reviews': 723,
      'image': 'assets/images/products/boots.jpg',
      'isNew': false,
    },
    {
      'name': 'Summer Dress',
      'price': 2999,
      'rating': 4.5,
      'reviews': 456,
      'image': 'assets/images/products/dress.jpg',
      'isNew': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final listHeight = isTablet ? 260.0 : 240.0;

    return Column(
      children: [
        SectionHeader(
          title: 'Trending Now',
          subtitle: 'Most popular this week',
          icon: Icons.trending_up_rounded,
          onViewAll: () {},
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _trendingProducts.length,
            itemBuilder: (context, index) {
              return _buildTrendingCard(
                _trendingProducts[index],
                index,
                isTablet: isTablet,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(
    Map<String, dynamic> product,
    int index, {
    required bool isTablet,
  }) {
    final cardWidth = isTablet ? 180.0 : 150.0;
    final imageHeight = isTablet ? 120.0 : 100.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with rank and new badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  product['image'],
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: imageHeight,
                      width: double.infinity,
                      color: AppColors.surfaceLight,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 45,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    );
                  },
                ),
              ),
              // Rank badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              // New badge
              if (product['isNew'])
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs ${product['price']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                // Rating
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.highlight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product['reviews']})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
