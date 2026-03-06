import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_all_products_screen.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class NewArrivalsSection extends StatefulWidget {
  const NewArrivalsSection({Key? key}) : super(key: key);

  @override
  State<NewArrivalsSection> createState() => _NewArrivalsSectionState();
}

class _NewArrivalsSectionState extends State<NewArrivalsSection> {
  late final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _productViewModel.addListener(_onStateChange);
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
    final listHeight = isTablet ? 240.0 : 220.0;

    // Get newest products (sorted by creation date) – show 6 on home, View All shows all
    final newArrivals = [...state.products];
    newArrivals.sort((a, b) {
      final DateTime aDate = a.createdAt != null
          ? DateTime.tryParse(a.createdAt!) ?? DateTime(2000)
          : DateTime(2000);
      final DateTime bDate = b.createdAt != null
          ? DateTime.tryParse(b.createdAt!) ?? DateTime(2000)
          : DateTime(2000);
      return bDate.compareTo(aDate);
    });
    final topNew = newArrivals.take(6).toList();

    List<ProductEntity> _allNewArrivals(List<ProductEntity> all) {
      final sorted = [...all];
      sorted.sort((a, b) {
        final aDate = a.createdAt != null
            ? DateTime.tryParse(a.createdAt!) ?? DateTime(2000)
            : DateTime(2000);
        final bDate = b.createdAt != null
            ? DateTime.tryParse(b.createdAt!) ?? DateTime(2000)
            : DateTime(2000);
        return bDate.compareTo(aDate);
      });
      return sorted;
    }

    if (topNew.isEmpty && state.status != ProductStatus.loading) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SectionHeader(
          title: 'New Arrivals',
          subtitle: 'Fresh products just landed',
          icon: Icons.new_releases_rounded,
          onViewAll: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerAllProductsScreen(
                title: 'New Arrivals',
                subtitle: 'All our latest products',
                icon: Icons.new_releases_rounded,
                filterFn: _allNewArrivals,
              ),
            ),
          ),
        ),
        if (state.status == ProductStatus.loading && state.products.isEmpty)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (topNew.isNotEmpty)
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: topNew.length,
              itemBuilder: (context, index) {
                return _buildNewArrivalCard(
                  topNew[index],
                  isTablet: isTablet,
                  context: context,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNewArrivalCard(
    product, {
    required bool isTablet,
    required BuildContext context,
  }) {
    final cardWidth = isTablet ? 210.0 : 180.0;
    final imageHeight = isTablet ? 120.0 : 100.0;

    // Calculate days ago
    final now = DateTime.now();
    final createdAt = product.createdAt != null
        ? DateTime.tryParse(product.createdAt!) ?? now
        : now;
    final daysAgo = now.difference(createdAt).inDays;

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
            // Product Image with category
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
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.primaryLight.withValues(
                                      alpha: 0.5,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.local_offer_outlined,
                                size: 45,
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primaryLight.withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.local_offer_outlined,
                            size: 45,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                ),
                if (daysAgo <= 7)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        daysAgo == 0 ? 'NEW' : '${daysAgo}d ago',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      if (daysAgo <= 7)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            daysAgo == 0 ? 'Today' : '${daysAgo}d',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
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
