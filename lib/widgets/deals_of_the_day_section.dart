import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_all_products_screen.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class DealsOfTheDaySection extends StatefulWidget {
  const DealsOfTheDaySection({Key? key}) : super(key: key);

  @override
  State<DealsOfTheDaySection> createState() => _DealsOfTheDaySectionState();
}

class _DealsOfTheDaySectionState extends State<DealsOfTheDaySection> {
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

    // Get products with discounts for deals – show 3 on home, View All shows all deals
    final deals = state.products
        .where((p) => p.discountPrice != null && p.discountPrice! < p.price)
        .take(3)
        .toList();

    List<ProductEntity> _allDeals(List<ProductEntity> all) => all
        .where((p) => p.discountPrice != null && p.discountPrice! < p.price)
        .toList();

    if (deals.isEmpty && state.status != ProductStatus.loading) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SectionHeader(
          title: 'Deals of the Day',
          subtitle: "Don't miss out today's deals",
          icon: Icons.local_fire_department_rounded,
          onViewAll: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerAllProductsScreen(
                title: 'Deals of the Day',
                subtitle: 'All discounted products',
                icon: Icons.local_fire_department_rounded,
                filterFn: _allDeals,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isTablet
                ? Row(
                    children: deals
                        .asMap()
                        .entries
                        .map(
                          (entry) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: entry.key == deals.length - 1 ? 0 : 12,
                              ),
                              child: _buildDealCard(
                                entry.value,
                                isTablet: isTablet,
                                context: context,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                : Column(
                    children: deals
                        .map(
                          (deal) => _buildDealCard(
                            deal,
                            isTablet: isTablet,
                            context: context,
                          ),
                        )
                        .toList(),
                  ),
          ),
      ],
    );
  }

  Widget _buildDealCard(
    deal, {
    required bool isTablet,
    required BuildContext context,
  }) {
    final imageWidth = isTablet ? 140.0 : 120.0;
    final imageHeight = isTablet ? 140.0 : 120.0;

    // Calculate discount percentage
    final discountPercent = deal.discountPrice != null
        ? ((deal.price - deal.discountPrice!) / deal.price * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CustomerProductDetailScreen(productId: deal.id),
          ),
        );
      },
      child: Container(
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
                  child: deal.images.isNotEmpty
                      ? Image.network(
                          ImageHelper.fixImageUrl(deal.images[0]),
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: imageWidth,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                              ),
                              child: const Icon(
                                Icons.local_offer_outlined,
                                size: 45,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: imageWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16),
                            ),
                          ),
                          child: const Icon(
                            Icons.local_offer_outlined,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                ),
                if (discountPercent > 0)
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
                        '-$discountPercent%',
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
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                          'Rs ${deal.discountPrice ?? deal.price}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (deal.discountPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Rs ${deal.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            size: 14,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Save $discountPercent%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
