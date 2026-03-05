import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/order_entity.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import '../../providers/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderEntity order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late OrderEntity _order;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFresh());
  }

  Future<void> _fetchFresh() async {
    if (!mounted) return;
    setState(() => _refreshing = true);
    await OrderProvider.instance.getOrderById(widget.order.id);
    if (mounted) {
      final fresh = OrderProvider.instance.state.selectedOrder;
      setState(() {
        if (fresh != null) _order = fresh;
        _refreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Order #${_order.id.substring(_order.id.length - 8).toUpperCase()}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Status tracker
              _buildStatusTracker(_order.orderStatus, _order.createdAt),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Items card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(
                            Icons.shopping_bag_outlined,
                            'Items (${_order.items.length})',
                          ),
                          const SizedBox(height: 4),
                          ..._order.items.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            return Column(
                              children: [
                                if (i > 0)
                                  const Divider(
                                    height: 1,
                                    color: AppColors.borderLight,
                                  ),
                                _buildOrderItem(item),
                              ],
                            );
                          }),
                          const Divider(
                            height: 24,
                            color: AppColors.borderLight,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Rs. ${_order.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Shipping address card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(
                            Icons.location_on_outlined,
                            'Shipping Address',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person_outline,
                            _order.shippingAddress.fullName,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.phone_outlined,
                            _order.shippingAddress.phone,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.home_outlined,
                            '${_order.shippingAddress.street}, ${_order.shippingAddress.city}',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.map_outlined,
                            '${_order.shippingAddress.state}, ${_order.shippingAddress.country}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Payment card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(Icons.payment_outlined, 'Payment'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPaymentChip(
                                  label: _formatPaymentMethod(
                                    _order.paymentMethod,
                                  ),
                                  icon: Icons.account_balance_wallet_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildPaymentChip(
                                  label: _formatPaymentStatus(
                                    _order.paymentStatus,
                                  ),
                                  icon: _order.paymentStatus == 'paid'
                                      ? Icons.check_circle_outline
                                      : _order.paymentStatus == 'failed'
                                      ? Icons.cancel_outlined
                                      : _order.paymentStatus == 'refunded'
                                      ? Icons.replay_outlined
                                      : Icons.hourglass_bottom_outlined,
                                  color: _order.paymentStatus == 'paid'
                                      ? AppColors.success
                                      : _order.paymentStatus == 'failed'
                                      ? AppColors.error
                                      : AppColors.warning,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTracker(String status, DateTime createdAt) {
    const steps = [
      _StepInfo('placed', 'Placed', Icons.receipt_long_outlined),
      _StepInfo('confirmed', 'Confirmed', Icons.verified_outlined),
      _StepInfo('processing', 'Processing', Icons.inventory_2_outlined),
      _StepInfo('shipped', 'Shipped', Icons.local_shipping_outlined),
      _StepInfo('delivered', 'Delivered', Icons.done_all_rounded),
    ];

    final isCancelled = status.toLowerCase() == 'cancelled';
    final currentIndex = isCancelled
        ? -1
        : steps.indexWhere((s) => s.key == status.toLowerCase());
    final activeIndex = currentIndex == -1 ? 0 : currentIndex;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCancelled ? Icons.cancel_outlined : Icons.local_mall_outlined,
                size: 16,
                color: isCancelled ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                isCancelled ? 'Order Cancelled' : 'Order Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCancelled ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Placed ${DateFormat('MMM d, yyyy').format(createdAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
          if (isCancelled) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  const Text(
                    'This order has been cancelled.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            // Step dots + connector line
            Row(
              children: List.generate(steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  // Connector line
                  final stepIndex = (i - 1) ~/ 2;
                  final filled = stepIndex < activeIndex;
                  return Expanded(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: filled
                            ? AppColors.primary
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                } else {
                  // Step dot
                  final stepIndex = i ~/ 2;
                  final isDone = stepIndex < activeIndex;
                  final isActive = stepIndex == activeIndex;
                  return _buildStepDot(
                    steps[stepIndex].icon,
                    isDone: isDone,
                    isActive: isActive,
                  );
                }
              }),
            ),
            const SizedBox(height: 8),
            // Step labels
            Row(
              children: List.generate(steps.length * 2 - 1, (i) {
                if (i.isOdd) return const Expanded(child: SizedBox());
                final stepIndex = i ~/ 2;
                final isDone = stepIndex < activeIndex;
                final isActive = stepIndex == activeIndex;
                return SizedBox(
                  width: 52,
                  child: Text(
                    steps[stepIndex].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive
                          ? AppColors.primary
                          : isDone
                          ? AppColors.textSecondary
                          : AppColors.textHint,
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepDot(
    IconData icon, {
    required bool isDone,
    required bool isActive,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? AppColors.primary
            : isActive
            ? AppColors.primary
            : AppColors.borderLight,
        border: isActive
            ? Border.all(color: AppColors.primary, width: 2.5)
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        isDone ? Icons.check_rounded : icon,
        size: 18,
        color: (isDone || isActive) ? Colors.white : AppColors.textHint,
      ),
    );
  }

  Widget _buildOrderItem(OrderItemEntity item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.image != null
                ? Image.network(
                    ImageHelper.fixImageUrl(item.image!),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × Rs. ${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.attributes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildAttributes(item.attributes),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs. ${(item.quantity * item.price).toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.textHint,
        size: 28,
      ),
    );
  }

  Widget _buildAttributes(Map<String, dynamic> attributes) {
    final parts = <String>[];
    for (final entry in attributes.entries) {
      final v = entry.value;
      if (v is List) {
        for (final opt in v) {
          if (opt is Map) parts.add('${entry.key}: ${opt['value']}');
        }
      } else {
        parts.add('${entry.key}: $v');
      }
    }
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: parts
          .map(
            (p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                p,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      case 'esewa':
        return 'eSewa';
      case 'khalti':
        return 'Khalti';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
            )
            .join(' ');
    }
  }

  String _formatPaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
            )
            .join(' ');
    }
  }
}

class _StepInfo {
  final String key;
  final String label;
  final IconData icon;
  const _StepInfo(this.key, this.label, this.icon);
}
