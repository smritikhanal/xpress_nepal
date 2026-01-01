import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_colors.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class DealsOfTheDaySection extends StatelessWidget {
  const DealsOfTheDaySection({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> _deals = [
    {
      'name': 'iPhone 15 Pro Max',
      'originalPrice': 210000,
      'dealPrice': 190000,
      'discount': 10,
      'endsIn': 'Today',
      'image': 'assets/images/products/iphone.jpg',
    },
    {
      'name': 'Samsung Galaxy S24 Ultra',
      'originalPrice': 120000,
      'dealPrice': 85550,
      'discount': 29,
      'endsIn': 'Today',
      'image': 'assets/images/products/samsung.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;

    return Column(
      children: [
        SectionHeader(
          title: 'Deals of the Day',
          subtitle: "Don't miss out today's deals",
          icon: Icons.local_fire_department_rounded,
          onViewAll: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isTablet
              ? Row(
                  children: _deals
                      .map(
                        (deal) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildDealCard(deal, isTablet: isTablet),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: _deals
                      .map((deal) => _buildDealCard(deal, isTablet: isTablet))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal, {required bool isTablet}) {
    final imageWidth = isTablet ? 140.0 : 120.0;
    final imageHeight = isTablet ? 140.0 : 120.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.asset(
                  deal['image'],
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: imageWidth,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primaryLight.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 50,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${deal['discount']}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Deal Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rs ${deal['dealPrice']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rs ${deal['originalPrice']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ends ${deal['endsIn']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
