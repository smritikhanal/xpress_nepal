import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_colors.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> _categories = [
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'items': 1234},
    {'name': 'Electronics', 'icon': Icons.devices_rounded, 'items': 856},
    {'name': 'Home', 'icon': Icons.home_rounded, 'items': 654},
    {'name': 'Sports', 'icon': Icons.sports_basketball_rounded, 'items': 432},
    {'name': 'Beauty', 'icon': Icons.face_rounded, 'items': 567},
    {'name': 'Books', 'icon': Icons.menu_book_rounded, 'items': 890},
    {'name': 'Toys', 'icon': Icons.toys_rounded, 'items': 321},
    {'name': 'More', 'icon': Icons.more_horiz_rounded, 'items': 0},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final crossAxisCount = isTablet ? 8 : 4;
    final childAspectRatio = isTablet ? 1.0 : 0.9;

    return Column(
      children: [
        SectionHeader(
          title: 'Shop by Category',
          subtitle: 'Browse our collections',
          icon: Icons.category_rounded,
          onViewAll: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(_categories[index], isTablet: isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    Map<String, dynamic> category, {
    required bool isTablet,
  }) {
    final iconContainerSize = isTablet ? 70.0 : 60.0;
    final iconSize = isTablet ? 32.0 : 28.0;

    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              category['icon'],
              color: AppColors.primary,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category['name'],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
