import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/app/theme/app_theme.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:xpress_nepal/features/product/presentation/pages/create_product_page.dart';
import 'package:xpress_nepal/features/product/presentation/pages/view_products_page.dart';
import 'package:xpress_nepal/features/seller/presentation/pages/seller_edit_profile_screen.dart';
import 'package:xpress_nepal/features/order/presentation/pages/seller/seller_orders_page.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/order/presentation/providers/order_provider.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/change_password_screen.dart';
import 'package:xpress_nepal/features/messages/presentation/pages/messages_page.dart';
import 'package:xpress_nepal/features/messages/presentation/providers/message_provider.dart';
import 'package:xpress_nepal/features/seller/presentation/pages/seller_all_reviews_screen.dart';
import 'package:xpress_nepal/features/seller/presentation/pages/seller_shop_analytics_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final _authViewModel = AuthProvider.instance.authViewModel;
  int _selectedIndex = 0;

  void _onAuthStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _authViewModel.addListener(_onAuthStateChange);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthStateChange);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final sellerId = _authViewModel.state.user?.id;
    if (sellerId != null) {
      await Future.wait([
        ProductProvider.instance.productViewModel.loadProducts(
          sellerId: sellerId,
          refresh: true,
        ),
        OrderProvider.instance.getSellerOrders(refresh: true),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.sellerTheme,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildProductsMenu();
      case 2:
        // Show the real seller orders page
        return SellerOrdersPage();
      case 3:
        return const MessagesPage();
      case 4:
        return _buildProfileMenu();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
              _buildNavItem(1, Icons.inventory_2_rounded, 'Products'),
              _buildNavItem(2, Icons.shopping_bag_rounded, 'Orders'),
              _buildMessagesNavItem(),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesNavItem() {
    return ListenableBuilder(
      listenable: MessageProvider.instance.viewModel,
      builder: (context, _) {
        final unread = MessageProvider.instance.viewModel.unreadCount;
        final isSelected = _selectedIndex == 3;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = 3),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.sellerGradient : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.sellerPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.message_rounded,
                      size: 22,
                      color: isSelected ? Colors.white : AppColors.textHint,
                    ),
                    if (unread > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Text(
                    'Messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.sellerGradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.sellerPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.textHint,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final user = _authViewModel.state.user;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.sellerGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sellerPrimary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (user?.name ?? 'S')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.sellerPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              user?.name ?? 'Seller',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: ProductProvider.instance.productViewModel,
                    builder: (context, _) {
                      final sellerId = _authViewModel.state.user?.id;
                      final products = sellerId == null
                          ? []
                          : ProductProvider
                                .instance
                                .productViewModel
                                .state
                                .products
                                .where((p) => p.sellerId == sellerId)
                                .toList();
                      return _buildStatCard(
                        'Products',
                        products.length.toString(),
                        Icons.inventory_2_rounded,
                        AppColors.sellerPrimary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewProductsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListenableBuilder(
                    listenable: OrderProvider.instance,
                    builder: (context, _) {
                      final orders = OrderProvider.instance.state.sellerOrders;
                      return _buildStatCard(
                        'Orders',
                        orders.length.toString(),
                        Icons.shopping_bag_rounded,
                        Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SellerOrdersPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: OrderProvider.instance,
                    builder: (context, _) {
                      final revenue = OrderProvider.instance.state.sellerOrders
                          .fold<double>(0, (sum, o) => sum + o.totalAmount);
                      return _buildStatCard(
                        'Revenue',
                        'Rs. ${revenue.toStringAsFixed(0)}',
                        Icons.account_balance_wallet_rounded,
                        Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SellerShopAnalyticsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListenableBuilder(
                    listenable: ProductProvider.instance.productViewModel,
                    builder: (context, _) {
                      final sellerId = _authViewModel.state.user?.id;
                      final sellerProducts = sellerId == null
                          ? <ProductEntity>[]
                          : ProductProvider
                                .instance
                                .productViewModel
                                .state
                                .products
                                .where((p) => p.sellerId == sellerId)
                                .toList();
                      final totalReviews = sellerProducts.fold<int>(
                        0,
                        (sum, p) => sum + p.ratingCount,
                      );
                      return _buildStatCard(
                        'Reviews',
                        totalReviews.toString(),
                        Icons.star_rounded,
                        Colors.amber,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SellerAllReviewsScreen(
                              sellerId: _authViewModel.state.user?.id ?? '',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Add Product',
                    Icons.add_box_rounded,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateProductPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'View Orders',
                    Icons.list_alt_rounded,
                    () => setState(() => _selectedIndex = 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Reviews
            const Text(
              'Recent Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _SellerReviewsSection(
              sellerId: _authViewModel.state.user?.id ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsMenu() {
    return SafeArea(
      child: Column(
        children: [
          // Header with Search
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.sellerGradient,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your product listings',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                // Quick Search Bar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewProductsPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Search your products...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMenuTile(
                  icon: Icons.add_box_rounded,
                  title: 'Add New Product',
                  subtitle: 'Create a new product listing',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateProductPage(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Icons.inventory_2_rounded,
                  title: 'View All Products',
                  subtitle: 'See and manage your products',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewProductsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    final user = _authViewModel.state.user;
    final initials = (user?.name ?? 'S')
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.sellerGradient,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sellerPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Seller',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Seller Account',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Settings',
                    subtitle: 'View and edit your shop and user profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellerEditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),
                  _buildMenuTile(
                    icon: Icons.security,
                    title: 'Security',
                    subtitle: 'Change your password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Theme(
                            data: AppTheme.sellerTheme,
                            child: ChangePasswordScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'View details',
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.sellerPrimary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sellerPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.sellerPrimary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconBgColor = isDestructive
        ? AppColors.error.withOpacity(0.1)
        : AppColors.sellerPrimary.withOpacity(0.1);
    final iconColor = isDestructive ? AppColors.error : AppColors.sellerPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Seller Reviews Section ────────────────────────────────────────────────────
class _SellerReviewsSection extends StatefulWidget {
  final String sellerId;
  const _SellerReviewsSection({required this.sellerId});

  @override
  State<_SellerReviewsSection> createState() => _SellerReviewsSectionState();
}

class _SellerReviewsSectionState extends State<_SellerReviewsSection> {
  final _productViewModel = ProductProvider.instance.productViewModel;
  List<_ReviewWithProduct> _reviews = [];
  bool _isLoading = true;
  String? _error;
  int _lastProductCount = -1;

  @override
  void initState() {
    super.initState();
    _productViewModel.addListener(_onProductsChanged);
    _loadReviews();
  }

  @override
  void dispose() {
    _productViewModel.removeListener(_onProductsChanged);
    super.dispose();
  }

  void _onProductsChanged() {
    final count = _productViewModel.state.products
        .where((p) => p.sellerId == widget.sellerId)
        .length;
    if (count != _lastProductCount && !_isLoading) {
      _loadReviews();
    }
  }

  Future<void> _loadReviews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = _productViewModel.state.products
          .where((p) => p.sellerId == widget.sellerId)
          .toList();
      _lastProductCount = products.length;
      final List<_ReviewWithProduct> all = [];
      for (final product in products) {
        final reviews = await _productViewModel.fetchProductReviews(product.id);
        for (final r in reviews) {
          all.add(_ReviewWithProduct(review: r, productTitle: product.title));
        }
      }
      // Sort by newest first
      all.sort((a, b) {
        final aDate = a.review.createdAt ?? '';
        final bDate = b.review.createdAt ?? '';
        return bDate.compareTo(aDate);
      });
      // Keep only reviews from the last 24 hours
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      final recent = all.where((item) {
        if (item.review.createdAt == null ||
            (item.review.createdAt as String).isEmpty)
          return true;
        try {
          return DateTime.parse(
            item.review.createdAt as String,
          ).isAfter(cutoff);
        } catch (_) {
          return true;
        }
      }).toList();
      if (mounted) {
        setState(() {
          _reviews = recent.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Failed to load reviews',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: _loadReviews,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.sellerPrimary),
              ),
            ),
          ],
        ),
      );
    }
    if (_reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.star_border_rounded,
                size: 40,
                color: AppColors.textHint,
              ),
              SizedBox(height: 8),
              Text(
                'No reviews in the last 24 hours',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: _reviews.map((item) => _buildReviewCard(item)).toList(),
    );
  }

  Widget _buildReviewCard(_ReviewWithProduct item) {
    final r = item.review;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.sellerPrimaryLight,
                child: Text(
                  (r.userName ?? r.userId)[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.sellerPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.userName ?? 'Customer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.productTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < r.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewWithProduct {
  final dynamic review;
  final String productTitle;
  const _ReviewWithProduct({required this.review, required this.productTitle});
}

extension on _SellerDashboardScreenState {
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
              backgroundColor: AppColors.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authViewModel.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
