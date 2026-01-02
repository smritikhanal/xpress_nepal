import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_colors.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/widgets/home_app_bar.dart';
import 'package:xpress_nepal/widgets/promo_banner.dart';
import 'package:xpress_nepal/widgets/categories_section.dart';
import 'package:xpress_nepal/widgets/flash_sale_section.dart';
import 'package:xpress_nepal/widgets/trending_products_section.dart';
import 'package:xpress_nepal/widgets/new_arrivals_section.dart';
import 'package:xpress_nepal/widgets/deals_of_the_day_section.dart';
import 'package:xpress_nepal/widgets/top_sellers_section.dart';
import 'package:xpress_nepal/widgets/product_grid.dart';
import 'package:xpress_nepal/widgets/home_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthProvider.instance.authViewModel.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 650;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppBar(onLogout: _handleLogout),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 8),
              // Promo Banner
              PromoBanner(),
              SizedBox(height: 16),

              // Categories
              CategoriesSection(),
              SizedBox(height: 20),

              // Flash Sale with countdown
              FlashSaleSection(),
              SizedBox(height: 20),

              // Trending Products
              TrendingProductsSection(),
              SizedBox(height: 20),

              // New Arrivals
              NewArrivalsSection(),
              SizedBox(height: 20),

              // Deals of the Day
              DealsOfTheDaySection(),
              SizedBox(height: 20),

              // All Products Grid
              ProductGrid(),
              SizedBox(height: 20),

              // Top Sellers
              TopSellersSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        isTablet: isTablet,
      ),
    );
  }
}
