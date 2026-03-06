import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/home/presentation/providers/home_content_provider.dart';
import 'package:xpress_nepal/widgets/section_header.dart';
import 'package:xpress_nepal/features/home/presentation/pages/customer_search_screen.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allCategories = context.watch<HomeContentProvider>().categories;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;

    // Show all categories
    final categories = allCategories;

    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(
          title: 'Shop by Category',
          subtitle: 'Browse our collections',
          icon: Icons.category_rounded,
          onViewAll: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerSearchScreen(),
              ),
            );

            // When returning from search, reload all products without filters
            if (context.mounted) {
              ProductProvider.instance.productViewModel.loadProducts(
                refresh: true,
              );
            }
          },
        ),
        SizedBox(
          height: isTablet ? 120 : 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < categories.length - 1 ? 16 : 0,
                ),
                child: _buildCategoryItem(
                  context,
                  categories[index],
                  isTablet: isTablet,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Map<String, dynamic> category, {
    required bool isTablet,
  }) {
    final iconContainerSize = isTablet ? 70.0 : 60.0;
    final iconSize = isTablet ? 32.0 : 28.0;

    return GestureDetector(
      onTap: () async {
        // Navigate to search screen with category filter
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerSearchScreenWithCategory(
              categoryName: category['name'] as String,
            ),
          ),
        );

        // When returning from search, reload all products without filters
        if (context.mounted) {
          ProductProvider.instance.productViewModel.loadProducts(refresh: true);
        }
      },
      child: SizedBox(
        width: isTablet ? 90 : 80,
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
            Flexible(
              child: Text(
                category['name'],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
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
      case 'shopping_basket_rounded':
        return Icons.shopping_basket_rounded;
      case 'watch_rounded':
        return Icons.watch_rounded;
      case 'directions_car_rounded':
        return Icons.directions_car_rounded;
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
