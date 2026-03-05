import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({Key? key}) : super(key: key);

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Timer _timer;
  Duration _remainingTime = const Duration(hours: 5, minutes: 32, seconds: 18);
  late final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    _timer.cancel();
    _productViewModel.removeListener(_onStateChange);
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _productViewModel.state;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final listHeight = isTablet ? 280.0 : 260.0;

    // Get products with discounts for flash sale
    final flashSaleProducts = state.products
        .where(
          (p) =>
              p.discountPrice != null &&
              p.discountPrice! > 0 &&
              p.discountPrice! < p.price,
        )
        .take(10)
        .toList();

    if (flashSaleProducts.isEmpty && state.status != ProductStatus.loading) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SectionHeader(
          title: 'Flash Sale',
          subtitle: 'Hurry up! Limited time offer',
          icon: Icons.flash_on_rounded,
          trailing: _buildCountdownTimer(),
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
              itemCount: flashSaleProducts.length,
              itemBuilder: (context, index) {
                return _buildFlashSaleCard(
                  flashSaleProducts[index],
                  isTablet: isTablet,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    final hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '$hours:$minutes:$seconds',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleCard(product, {required bool isTablet}) {
    final cardWidth = isTablet ? 200.0 : 160.0;
    final imageHeight = isTablet ? 120.0 : 100.0;

    // Calculate discount percentage
    final discountPercent =
        (product.discountPrice != null && product.discountPrice! > 0)
        ? ((product.price - product.discountPrice!) / product.price * 100)
              .round()
        : 0;

    // For sold percentage, we'll use stock availability as proxy
    final soldPercent = product.stock > 0
        ? ((100 - product.stock) / 100 * 100).clamp(0, 100).round()
        : 90; // Show 90% sold if out of stock

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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image with discount badge
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
                                Icons.shopping_bag_outlined,
                                size: isTablet ? 50 : 40,
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
                            Icons.shopping_bag_outlined,
                            size: isTablet ? 50 : 40,
                            color: AppColors.primary.withValues(alpha: 0.5),
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
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 12 : 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs ${product.discountPrice != null && product.discountPrice! > 0 ? product.discountPrice! : product.price}',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.discountPrice != null &&
                            product.discountPrice! > 0 &&
                            product.discountPrice! < product.price)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Rs ${product.price}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: soldPercent / 100,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: isTablet ? 6 : 5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$soldPercent% sold',
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            color: AppColors.textSecondary,
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
      ),
    );
  }
}
