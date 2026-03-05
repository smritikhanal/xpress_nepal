import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/home/presentation/providers/home_content_provider.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/widgets/section_header.dart';
import 'package:xpress_nepal/features/home/presentation/pages/customer_search_screen.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({Key? key}) : super(key: key);

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  late final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _productViewModel.addListener(_onProductsChanged);
    if (_productViewModel.state.products.isEmpty) {
      _productViewModel.loadProducts(refresh: true);
    }
  }

  void _onProductsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _productViewModel.removeListener(_onProductsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = context.watch<HomeContentProvider>().categories;
    final productState = _productViewModel.state;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final crossAxisCount = isTablet ? 8 : 4;
    final childAspectRatio = isTablet ? 1.0 : 0.9;

    // Build set of category names that have at least one product
    final activeCategoryNames = productState.products
        .where((p) => p.categoryName != null && p.categoryName!.isNotEmpty)
        .map((p) => p.categoryName!.toLowerCase().trim())
        .toSet();

    // Only show categories that have matching products (or all if products not loaded yet)
    final categories =
        productState.status == ProductStatus.loading ||
            productState.products.isEmpty
        ? allCategories
        : allCategories.where((cat) {
            final name = (cat['name'] as String? ?? '').toLowerCase().trim();
            return activeCategoryNames.contains(name);
          }).toList();

    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(
          title: 'Shop by Category',
          subtitle: 'Browse our collections',
          icon: Icons.category_rounded,
          onViewAll: () {},
        ),
        if (productState.status == ProductStatus.loading &&
            productState.products.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          )
        else
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
                return _buildCategoryItem(
                  context,
                  categories[index],
                  isTablet: isTablet,
                );
              },
            ),
          ),
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
      onTap: () {
        // Navigate to search screen with category filter
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerSearchScreenWithCategory(
              categoryName: category['name'] as String,
            ),
          ),
        );
      },
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
