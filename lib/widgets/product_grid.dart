import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_all_products_screen.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/widgets/section_header.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';

class ProductGrid extends StatefulWidget {
  /// When set, only this many products are shown on the home page.
  /// A "View All" button is displayed that navigates to the full list.
  final int? limit;

  const ProductGrid({super.key, this.limit});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  late final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _productViewModel.addListener(_onStateChange);
    _productViewModel.loadProducts(refresh: true);
  }

  @override
  void dispose() {
    _productViewModel.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final isDesktop = screenWidth >= 1024;

    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Column(
      children: [
        SectionHeader(
          title: 'All Products',
          subtitle: 'Browse our collection',
          icon: Icons.shopping_bag_rounded,
          onViewAll: widget.limit != null
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerAllProductsScreen(
                      title: 'All Products',
                      subtitle: 'Browse our complete collection',
                      icon: Icons.shopping_bag_rounded,
                      filterFn: (products) => products,
                    ),
                  ),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildProductGrid(crossAxisCount, isTablet),
        ),
      ],
    );
  }

  Widget _buildProductGrid(int crossAxisCount, bool isTablet) {
    final state = _productViewModel.state;

    // Show loading indicator
    if (state.status == ProductStatus.loading && state.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (state.status == ProductStatus.error) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Failed to load products',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _productViewModel.loadProducts(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (state.products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              const Text(
                'No products available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Apply limit when set (home page preview)
    final displayProducts = widget.limit != null
        ? state.products.take(widget.limit!).toList()
        : state.products;

    // Show products from backend
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 0.72 : 0.68,
      ),
      itemBuilder: (context, index) {
        return ProductCardFromEntity(product: displayProducts[index]);
      },
    );
  }
}

/// Product card for ProductEntity (backend data)
class ProductCardFromEntity extends StatelessWidget {
  final ProductEntity product;

  const ProductCardFromEntity({super.key, required this.product});

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerProductDetailScreen(
          productId: product.id,
          product: product,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.discountPrice != null &&
        product.discountPrice! > 0 &&
        product.discountPrice! < product.price;
    final displayPrice = hasDiscount ? product.discountPrice! : product.price;
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: imageUrl != null
                        ? Image.network(
                            ImageHelper.fixImageUrl(imageUrl),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                  // Discount badge
                  if (hasDiscount)
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
                          '-${((1 - product.discountPrice! / product.price) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, _) {
                        final isWishlisted = wishlistProvider.isWishlisted(
                          product,
                        );
                        return GestureDetector(
                          onTap: () => wishlistProvider.toggleWishlist(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                              color: isWishlisted
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs. ${displayPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Rs. ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.ratingAvg.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        ' (${product.ratingCount})',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
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

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceLight,
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 50,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }
}
