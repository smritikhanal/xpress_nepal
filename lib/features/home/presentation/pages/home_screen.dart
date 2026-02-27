import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isRefreshingHomeContent = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);

  static const double _shakeThreshold = 12.0;
  static const Duration _shakeDebounce = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    // Listen to cart changes for badge updates
    CartProvider.instance.addListener(_onCartChanged);
    // Temporarily disabled on emulator due intermittent sensors plugin
    // channel availability issues that throw MissingPluginException on startup.
    // Keep home refresh stable via pull-to-refresh and manual actions.
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

  void _startShakeDetection() {
    try {
      _accelerometerSubscription = accelerometerEvents.listen(
        (event) {
          if (_selectedIndex != 0 || _isRefreshingHomeContent) return;

          final acceleration = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );

          final now = DateTime.now();
          final isDebounced = now.difference(_lastShakeTime) < _shakeDebounce;

          if (acceleration > _shakeThreshold && !isDebounced) {
            _lastShakeTime = now;
            unawaited(_refreshHomeContent(triggeredByShake: true));
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (error is MissingPluginException || error is PlatformException) {
            _accelerometerSubscription?.cancel();
            _accelerometerSubscription = null;
          }
        },
      );
    } on MissingPluginException {
      _accelerometerSubscription = null;
    } on PlatformException {
      _accelerometerSubscription = null;
    }
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
                ? 'Home page refreshed from offline cache (shake)'
                : 'Home page refreshed (offline mode)')
          : (triggeredByShake
                ? 'Home page refreshed via shake'
                : 'Home page refreshed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(refreshMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to refresh home content right now'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isRefreshingHomeContent = false;
      });
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
        onTap: (index) => setState(() => _selectedIndex = index),
        isTablet: isTablet,
        cartItemCount: CartProvider.instance.state.items.length,
      ),
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
            SizedBox(height: 8),
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

            // All Products Grid
            const ProductGrid(),
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
