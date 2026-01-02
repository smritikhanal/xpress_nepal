import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_colors.dart';
import 'package:xpress_nepal/widgets/section_header.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({Key? key}) : super(key: key);

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Timer _timer;
  Duration _remainingTime = const Duration(hours: 5, minutes: 32, seconds: 18);

  final List<Map<String, dynamic>> _flashSaleProducts = [
    {
      'name': 'iPhone 15 Pro',
      'originalPrice': 199000,
      'salePrice': 179000,
      'discount': 10,
      'sold': 156,
      'total': 200,
      'image': 'assets/images/products/iphone.jpg',
    },
    {
      'name': 'Samsung Galaxy S24',
      'originalPrice': 95000,
      'salePrice': 85550,
      'discount': 10,
      'sold': 89,
      'total': 150,
      'image': 'assets/images/products/samsung.jpg',
    },
    {
      'name': 'Winter Jacket',
      'originalPrice': 2500,
      'salePrice': 1520,
      'discount': 40,
      'sold': 234,
      'total': 300,
      'image': 'assets/images/products/winterjacket.jpg',
    },
    {
      'name': 'Razer Blade Laptop',
      'originalPrice': 250000,
      'salePrice': 199000,
      'discount': 20,
      'sold': 45,
      'total': 100,
      'image': 'assets/images/products/razerblade.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final listHeight = isTablet ? 280.0 : 260.0;

    return Column(
      children: [
        SectionHeader(
          title: 'Flash Sale',
          subtitle: 'Hurry up! Limited time offer',
          icon: Icons.flash_on_rounded,
          trailing: _buildCountdownTimer(),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _flashSaleProducts.length,
            itemBuilder: (context, index) {
              return _buildFlashSaleCard(
                _flashSaleProducts[index],
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

  Widget _buildFlashSaleCard(
    Map<String, dynamic> product, {
    required bool isTablet,
  }) {
    final soldPercent = (product['sold'] / product['total'] * 100).round();
    final cardWidth = isTablet ? 200.0 : 160.0;
    final imageHeight = isTablet ? 120.0 : 100.0;

    return Container(
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
                child: Image.asset(
                  product['image'],
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${product['discount']}%',
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
                    product['name'],
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
                        'Rs ${product['salePrice']}',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rs ${product['originalPrice']}',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          value: product['sold'] / product['total'],
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
    );
  }
}
