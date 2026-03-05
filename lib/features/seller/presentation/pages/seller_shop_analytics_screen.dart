import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/order/domain/models/order_entity.dart';
import 'package:xpress_nepal/features/order/presentation/providers/order_provider.dart';
import 'package:xpress_nepal/features/order/presentation/pages/seller/seller_status_orders_page.dart';

class SellerShopAnalyticsScreen extends StatefulWidget {
  const SellerShopAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<SellerShopAnalyticsScreen> createState() =>
      _SellerShopAnalyticsScreenState();
}

class _SellerShopAnalyticsScreenState extends State<SellerShopAnalyticsScreen> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await OrderProvider.instance.getSellerOrders(refresh: true);
    if (mounted) setState(() => _isRefreshing = false);
  }

  // ── Computed analytics from order list ──────────────────────────────────────

  double _totalRevenue(List<OrderEntity> orders) =>
      orders.fold(0, (s, o) => s + o.totalAmount);

  double _avgOrderValue(List<OrderEntity> orders) =>
      orders.isEmpty ? 0 : _totalRevenue(orders) / orders.length;

  Map<String, int> _statusCounts(List<OrderEntity> orders) {
    final map = <String, int>{};
    for (final o in orders) {
      final key = o.orderStatus.toLowerCase();
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  /// Returns [{productId, title, image, qty, revenue}] sorted by revenue desc
  List<_TopProduct> _topProducts(List<OrderEntity> orders) {
    final map = <String, _TopProduct>{};
    for (final order in orders) {
      for (final item in order.items) {
        final existing = map[item.productId];
        if (existing == null) {
          map[item.productId] = _TopProduct(
            productId: item.productId,
            title: item.title,
            image: item.image,
            totalQty: item.quantity,
            totalRevenue: item.price * item.quantity,
          );
        } else {
          map[item.productId] = _TopProduct(
            productId: item.productId,
            title: existing.title,
            image: existing.image,
            totalQty: existing.totalQty + item.quantity,
            totalRevenue: existing.totalRevenue + item.price * item.quantity,
          );
        }
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return list.take(5).toList();
  }

  /// Returns last 6 months revenue data
  List<_MonthlyRevenue> _monthlyRevenue(List<OrderEntity> orders) {
    final now = DateTime.now();
    final result = <_MonthlyRevenue>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final revenue = orders
          .where(
            (o) =>
                o.createdAt.year == month.year &&
                o.createdAt.month == month.month,
          )
          .fold<double>(0, (s, o) => s + o.totalAmount);
      result.add(_MonthlyRevenue(month: month, revenue: revenue));
    }
    return result;
  }

  // ── Status config ────────────────────────────────────────────────────────────

  static const _statusConfig = {
    'placed': (label: 'Placed', color: Color(0xFF6C63FF)),
    'confirmed': (label: 'Confirmed', color: Colors.blue),
    'processing': (label: 'Processing', color: AppColors.sellerPrimary),
    'shipped': (label: 'Shipped', color: Colors.indigo),
    'delivered': (label: 'Delivered', color: Color(0xFF00C462)),
    'cancelled': (label: 'Cancelled', color: Colors.red),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: OrderProvider.instance,
          builder: (context, _) {
            final orders = OrderProvider.instance.state.sellerOrders;
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.sellerPrimary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  if (_isRefreshing)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(child: _buildOverviewCards(orders)),
                    SliverToBoxAdapter(child: _buildStatusBreakdown(orders)),
                    SliverToBoxAdapter(child: _buildMonthlyChart(orders)),
                    SliverToBoxAdapter(child: _buildTopProducts(orders)),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.sellerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop Analytics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Overview of your store performance',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  // ── Overview Cards ──────────────────────────────────────────────────────────

  Widget _buildOverviewCards(List<OrderEntity> orders) {
    final revenue = _totalRevenue(orders);
    final avg = _avgOrderValue(orders);
    final delivered = orders
        .where((o) => o.orderStatus.toLowerCase() == 'delivered')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _analyticsCard(
                  title: 'Total Revenue',
                  value: 'Rs. ${revenue.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _analyticsCard(
                  title: 'Total Orders',
                  value: '${orders.length}',
                  icon: Icons.shopping_bag_rounded,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SellerStatusOrdersPage(title: 'All Orders'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _analyticsCard(
                  title: 'Avg Order Value',
                  value: 'Rs. ${avg.toStringAsFixed(0)}',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.sellerPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _analyticsCard(
                  title: 'Delivered',
                  value: '$delivered',
                  icon: Icons.done_all_rounded,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerStatusOrdersPage(
                        title: 'Delivered',
                        filterStatus: 'delivered',
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
  }

  Widget _analyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order Status Breakdown ──────────────────────────────────────────────────

  Widget _buildStatusBreakdown(List<OrderEntity> orders) {
    final counts = _statusCounts(orders);
    final total = orders.length;
    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
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
            const Text(
              'Order Status Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._statusConfig.entries.map((e) {
              final key = e.key;
              final config = e.value;
              final count = counts[key] ?? 0;
              final fraction = total > 0 ? count / total : 0.0;
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellerStatusOrdersPage(
                      title: config.label,
                      filterStatus: key,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          config.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: count > 0
                                ? config.color
                                : AppColors.textSecondary,
                            fontWeight: count > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: fraction.toDouble(),
                            backgroundColor: AppColors.borderLight,
                            color: config.color,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: count > 0
                                ? config.color
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Monthly Revenue Bar Chart ────────────────────────────────────────────────

  Widget _buildMonthlyChart(List<OrderEntity> orders) {
    final data = _monthlyRevenue(orders);
    final maxRevenue = data.fold<double>(
      0,
      (m, d) => d.revenue > m ? d.revenue : m,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
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
            const Text(
              'Monthly Revenue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Last 6 months',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((d) {
                  final fraction = maxRevenue > 0
                      ? d.revenue / maxRevenue
                      : 0.0;
                  final barHeight = 110 * fraction;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (d.revenue > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _shortAmount(d.revenue),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            height: barHeight.toDouble().clamp(4, 110),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.sellerPrimary,
                                  AppColors.sellerPrimaryDark,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _monthAbbr(d.month),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortAmount(double v) {
    if (v >= 1000) return 'Rs.${(v / 1000).toStringAsFixed(1)}k';
    return 'Rs.${v.toStringAsFixed(0)}';
  }

  String _monthAbbr(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return m[d.month - 1];
  }

  // ── Top Selling Products ──────────────────────────────────────────────────────

  Widget _buildTopProducts(List<OrderEntity> orders) {
    final top = _topProducts(orders);
    if (top.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
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
            const Text(
              'Top Selling Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'By total revenue',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...top.asMap().entries.map((e) {
              final rank = e.key + 1;
              final p = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? Colors.amber.withOpacity(0.15)
                            : rank == 2
                            ? Colors.grey.withOpacity(0.15)
                            : rank == 3
                            ? Colors.brown.withOpacity(0.15)
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rank == 1
                              ? Colors.amber.shade700
                              : rank == 2
                              ? Colors.grey.shade600
                              : rank == 3
                              ? Colors.brown
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${p.totalQty} units sold',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs. ${p.totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sellerPrimaryDark,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────────────────────

class _TopProduct {
  final String productId;
  final String title;
  final String? image;
  final int totalQty;
  final double totalRevenue;
  const _TopProduct({
    required this.productId,
    required this.title,
    this.image,
    required this.totalQty,
    required this.totalRevenue,
  });
}

class _MonthlyRevenue {
  final DateTime month;
  final double revenue;
  const _MonthlyRevenue({required this.month, required this.revenue});
}
