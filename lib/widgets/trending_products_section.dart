import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_all_products_screen.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class TrendingProductsSection extends StatefulWidget {
  const TrendingProductsSection({Key? key}) : super(key: key);

  @override
  State<TrendingProductsSection> createState() =>
      _TrendingProductsSectionState();
}

class _TrendingProductsSectionState extends State<TrendingProductsSection> {
  late final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _productViewModel.addListener(_onStateChange);
    // Load products if not already loaded
    if (_productViewModel.state.products.isEmpty) {
      _productViewModel.loadProducts(refresh: true);
    }
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _productViewModel.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _productViewModel.state;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final listHeight = isTablet ? 290.0 : 240.0;

    // Get trending products (sorted by rating) – show 6 on home, View All shows all
    final trendingProducts = [...state.products];
    trendingProducts.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    final topTrending = trendingProducts.take(6).toList();

    List<ProductEntity> _allTrending(List<ProductEntity> all) {
      final sorted = [...all];
      sorted.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      return sorted;
    }

    if (topTrending.isEmpty && state.status != ProductStatus.loading) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SectionHeader(
          title: 'Trending Now',
          subtitle: 'Most popular this week',
          icon: Icons.trending_up_rounded,
          onViewAll: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerAllProductsScreen(
                title: 'Trending Now',
                subtitle: 'Most popular products',
                icon: Icons.trending_up_rounded,
                filterFn: _allTrending,
              ),
            ),
          ),
        ),
        if (state.status == ProductStatus.loading)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: topTrending.length,
              itemBuilder: (context, index) {
                return _buildTrendingCard(
                  topTrending[index],
                  index,
                  isTablet: isTablet,
                  context: context,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTrendingCard(
    product,
    int index, {
    required bool isTablet,
    required BuildContext context,
  }) {
    final cardWidth = isTablet ? 180.0 : 150.0;
    final imageHeight = isTablet ? 120.0 : 100.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerProductDetailScreen(
              productId: product.id,
              product: product,
            ),
          ),
        );
      },
      child: Container(
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
            // Product Image with rank badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          ImageHelper.fixImageUrl(product.images[0]),
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.contain,
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
                        )
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: AppColors.surfaceLight,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 45,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
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
                // Discount badge if applicable
                if (product.discountPrice != null &&
                    product.discountPrice! > 0 &&
                    product.discountPrice! < product.price)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${((product.price - product.discountPrice!) / product.price * 100).round()}%',
                        style: const TextStyle(
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
                    product.title,
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
                    'Rs ${(product.discountPrice != null && product.discountPrice! > 0 ? product.discountPrice! : product.price).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (product.discountPrice != null &&
                      product.discountPrice! > 0 &&
                      product.discountPrice! < product.price)
                    Text(
                      'Rs ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.textSecondary,
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
                        '${product.ratingAvg ?? 0.0}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.ratingCount ?? 0})',
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
      ),
    );
  }
}
