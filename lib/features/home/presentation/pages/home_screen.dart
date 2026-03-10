import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/core/api/api_endpoints.dart';
import 'package:xpress_nepal/features/home/presentation/providers/home_content_provider.dart';
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
import 'package:xpress_nepal/features/home/presentation/pages/customer_profile_screen.dart';
import 'package:xpress_nepal/features/home/presentation/pages/customer_search_screen.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import '../../../../features/cart/cart.dart';
import '../../../../features/cart/presentation/provider/cart_provider.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isRefreshingHomeContent = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    CartProvider.instance.addListener(_onCartChanged);

    // Enable shake-to-refresh
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      // Simple shake detection: adjust threshold as needed
      final double shakeThreshold = 10.0;
      if (event.x.abs() > shakeThreshold ||
          event.y.abs() > shakeThreshold ||
          event.z.abs() > shakeThreshold) {
        _refreshHomeContent(triggeredByShake: true);
      }
    });
  }

  @override
  void dispose() {
    CartProvider.instance.removeListener(_onCartChanged);
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshHomeContent({bool triggeredByShake = false}) async {
    if (_selectedIndex != 0 || _isRefreshingHomeContent) return;

    setState(() {
      _isRefreshingHomeContent = true;
    });

    final homeContentProvider = context.read<HomeContentProvider>();

    try {
      await homeContentProvider.refreshAll();
      await ProductProvider.instance.productViewModel.loadProducts(
        refresh: true,
      );

      if (!mounted) return;

      final refreshMessage = homeContentProvider.isOfflineMode
          ? (triggeredByShake
                ? 'Refreshed (offline cache)'
                : 'Refreshed (offline)')
          : (triggeredByShake ? 'Refreshed via shake' : 'Page refreshed');

      _showRefreshToast(refreshMessage);
    } catch (_) {
      if (!mounted) return;
      _showRefreshToast('Unable to refresh right now', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isRefreshingHomeContent = false;
      });
    }
  }

  void _showRefreshToast(String message, {bool isError = false}) {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? AppColors.error : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: screenWidth * 0.45,
            bottom: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);

    // When returning to home tab, reload all products without filters
    if (index == 0) {
      ProductProvider.instance.productViewModel.loadProducts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 650;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _selectedIndex == 0
          ? HomeAppBar(onSearchTap: () => setState(() => _selectedIndex = 1))
          : null,
      body: _buildBody(),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onTabChanged,
        isTablet: isTablet,
        cartItemCount: CartProvider.instance.state.items.length,
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    final now = DateTime.now();
    final hour = now.hour;
    final String greeting;
    final IconData greetingIcon;
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.light_mode_rounded;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay_rounded;
    }

    return ListenableBuilder(
      listenable: AuthProvider.instance.authViewModel,
      builder: (context, _) {
        final user = AuthProvider.instance.authViewModel.state.user;
        final firstName = user?.name.split(' ').first ?? 'there';
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth >= 650;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 20,
            vertical: isTablet ? 20 : 18,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF9A5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                right: -18,
                top: -18,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -24,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              // Content
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting row
                        Row(
                          children: [
                            Icon(
                              greetingIcon,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              greeting,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Name
                        Text(
                          'Welcome, $firstName! 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 22 : 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tagline
                        Text(
                          'Discover the best deals today ✨',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: isTablet ? 13 : 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar
                  Container(
                    width: isTablet ? 56 : 48,
                    height: isTablet ? 56 : 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: user?.image != null
                          ? Image.network(
                              '${ApiEndpoints.baseUrl.replaceAll('/api', '')}/${user!.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    firstName.isNotEmpty
                                        ? firstName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 22 : 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 22 : 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const CustomerSearchScreen();
      case 2:
        return const CartPage();
      case 3:
        return const CustomerProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final providerLoading = context.watch<HomeContentProvider>().isLoading;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshHomeContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isRefreshingHomeContent || providerLoading)
              const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 4),
            // Welcome Banner
            _buildWelcomeBanner(),
            const SizedBox(height: 16),
            // Promo Banner
            const PromoBanner(),
            SizedBox(height: 16),

            // Categories
            const CategoriesSection(),
            SizedBox(height: 20),

            // Flash Sale with countdown
            const FlashSaleSection(),
            SizedBox(height: 20),

            // Trending Products
            const TrendingProductsSection(),
            SizedBox(height: 20),

            // New Arrivals
            const NewArrivalsSection(),
            SizedBox(height: 20),

            // Deals of the Day
            const DealsOfTheDaySection(),
            SizedBox(height: 20),

            // All Products Grid (limited preview – View All shows everything)
            const ProductGrid(limit: 4),
            SizedBox(height: 20),

            // Top Sellers
            const TopSellersSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
