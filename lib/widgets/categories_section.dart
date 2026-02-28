import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/home/presentation/providers/home_content_provider.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<HomeContentProvider>().categories;
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
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(categories[index], isTablet: isTablet);
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
              _resolveCategoryIcon(category['icon'] as String?),
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

  IconData _resolveCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'checkroom_rounded':
        return Icons.checkroom_rounded;
      case 'devices_rounded':
        return Icons.devices_rounded;
      case 'home_rounded':
        return Icons.home_rounded;
      case 'sports_basketball_rounded':
        return Icons.sports_basketball_rounded;
      case 'face_rounded':
        return Icons.face_rounded;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'toys_rounded':
        return Icons.toys_rounded;
      case 'more_horiz_rounded':
        return Icons.more_horiz_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
