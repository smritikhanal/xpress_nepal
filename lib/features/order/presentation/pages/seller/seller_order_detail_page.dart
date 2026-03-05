import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import '../../../domain/models/order_entity.dart';
import '../../view_model/order_view_model.dart';

class SellerOrderDetailPage extends StatefulWidget {
  final OrderEntity order;

  const SellerOrderDetailPage({super.key, required this.order});

  @override
  State<SellerOrderDetailPage> createState() => _SellerOrderDetailPageState();
}

class _SellerOrderDetailPageState extends State<SellerOrderDetailPage> {
  static const _statusSteps = ['placed', 'confirmed', 'shipped', 'delivered'];

  late OrderEntity _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  int _currentStepIndex(String status) {
    final idx = _statusSteps.indexOf(status.toLowerCase());
    return idx == -1 ? 0 : idx;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.sellerPrimary;
      case 'shipped':
        return Colors.blue;
      case 'confirmed':
        return Colors.purple;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  Color _paymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.sellerPrimary;
      case 'failed':
        return AppColors.error;
      case 'refunded':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _paymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle_outline;
      case 'failed':
        return Icons.cancel_outlined;
      case 'refunded':
        return Icons.replay_outlined;
      default:
        return Icons.hourglass_bottom_outlined;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.sellerPrimary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.4,
          right: 8,
          bottom: 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortId = _order.id.substring(_order.id.length - 8).toUpperCase();
    final dateStr = DateFormat('MMM d, yyyy · h:mm a').format(_order.createdAt);
    final currentStep = _currentStepIndex(_order.orderStatus);
    final isCancelled = _order.orderStatus.toLowerCase() == 'cancelled';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #$shortId'),
        backgroundColor: AppColors.sellerPrimaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ────────────────────────────────────────
            _card(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.sellerPrimaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.sellerPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$shortId',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(_order.orderStatus),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Status Stepper ─────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _smallEditButton(
                        label: 'Update',
                        onTap: () => _showOrderStatusDialog(context),
                      ),
                    ],
                  ),
                  if (isCancelled) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: AppColors.error,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'This order has been cancelled',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(_statusSteps.length, (i) {
                        final isCompleted = i <= currentStep;
                        final isActive = i == currentStep;
                        final isLast = i == _statusSteps.length - 1;
                        return Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      width: isActive ? 30 : 22,
                                      height: isActive ? 30 : 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted
                                            ? AppColors.sellerPrimary
                                            : AppColors.surfaceLight,
                                        border: Border.all(
                                          color: isCompleted
                                              ? AppColors.sellerPrimary
                                              : AppColors.borderLight,
                                          width: 2,
                                        ),
                                        boxShadow: isActive
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.sellerPrimary
                                                      .withOpacity(0.4),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Icon(
                                        isCompleted
                                            ? Icons.check
                                            : Icons.circle,
                                        size: isCompleted ? 14 : 8,
                                        color: isCompleted
                                            ? Colors.white
                                            : AppColors.textHint,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _statusSteps[i][0].toUpperCase() +
                                          _statusSteps[i].substring(1),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isCompleted
                                            ? AppColors.sellerPrimary
                                            : AppColors.textHint,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    color: i < currentStep
                                        ? AppColors.sellerPrimary
                                        : AppColors.borderLight,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Order Items ────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_order.items.length} ${_order.items.length == 1 ? 'item' : 'items'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._order.items.map((item) => _buildOrderItem(item)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Rs. ${_order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.sellerPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Shipping Address ───────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.location_on_rounded, 'Shipping Address'),
                  const SizedBox(height: 12),
                  _addressRow(
                    Icons.person_outline,
                    _order.shippingAddress.fullName,
                  ),
                  _addressRow(
                    Icons.phone_outlined,
                    _order.shippingAddress.phone,
                  ),
                  _addressRow(
                    Icons.home_outlined,
                    '${_order.shippingAddress.street}, ${_order.shippingAddress.city}',
                  ),
                  _addressRow(
                    Icons.map_outlined,
                    '${_order.shippingAddress.state}, ${_order.shippingAddress.country}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Payment Info ───────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader(Icons.payment_rounded, 'Payment Info'),
                      _smallEditButton(
                        label: 'Update',
                        onTap: () => _showPaymentStatusDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _paymentChip(
                        label: _order.paymentMethod
                            .replaceAll('_', ' ')
                            .split(' ')
                            .map((w) => w[0].toUpperCase() + w.substring(1))
                            .join(' '),
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.sellerPrimaryDark,
                      ),
                      const SizedBox(width: 8),
                      _paymentChip(
                        label: _order.paymentStatus.toUpperCase(),
                        icon: _paymentStatusIcon(_order.paymentStatus),
                        color: _paymentColor(_order.paymentStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItemEntity item) {
    final hasImage = item.image != null && item.image!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasImage
                ? Image.network(
                    ImageHelper.fixImageUrl(item.image!),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
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
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: item.attributes.entries.map((e) {
                      final val = e.value is List
                          ? (e.value as List)
                                .map((o) => o['value'] ?? '')
                                .join(', ')
                          : e.value.toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sellerPrimaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${e.key}: $val',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.sellerPrimaryDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          Text(
            'Rs. ${(item.quantity * item.price).toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.textHint,
        size: 24,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.sellerPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _addressRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
      ),
    );
  }

  Widget _smallEditButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.sellerPrimaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.sellerPrimary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.edit_outlined,
              size: 12,
              color: AppColors.sellerPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.sellerPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderStatusDialog(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    String? selectedStatus = _order.orderStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Update Order Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['confirmed', 'shipped', 'delivered', 'cancelled']
                .map(
                  (status) => RadioListTile<String>(
                    value: status,
                    groupValue: selectedStatus,
                    activeColor: AppColors.sellerPrimary,
                    onChanged: (val) =>
                        setDialogState(() => selectedStatus = val),
                    title: Text(status[0].toUpperCase() + status.substring(1)),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus == null) return;
                Navigator.pop(ctx);
                await viewModel.updateOrderStatus(_order.id, selectedStatus!);
                if (viewModel.state.errorMessage == null) {
                  final updated = viewModel.state.sellerOrders.firstWhere(
                    (o) => o.id == _order.id,
                    orElse: () => _order.copyWith(orderStatus: selectedStatus!),
                  );
                  if (mounted) setState(() => _order = updated);
                  _showSnackBar(
                    'Order status updated to ${selectedStatus![0].toUpperCase()}${selectedStatus!.substring(1)}',
                  );
                } else {
                  _showSnackBar(viewModel.state.errorMessage!, isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentStatusDialog(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    String? selectedStatus = _order.paymentStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Update Payment Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['pending', 'paid', 'failed', 'refunded']
                .map(
                  (status) => RadioListTile<String>(
                    value: status,
                    groupValue: selectedStatus,
                    activeColor: AppColors.sellerPrimary,
                    onChanged: (val) =>
                        setDialogState(() => selectedStatus = val),
                    title: Text(status[0].toUpperCase() + status.substring(1)),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus == null) return;
                Navigator.pop(ctx);
                await viewModel.updatePaymentStatus(_order.id, selectedStatus!);
                if (viewModel.state.errorMessage == null) {
                  final updated = viewModel.state.sellerOrders.firstWhere(
                    (o) => o.id == _order.id,
                    orElse: () =>
                        _order.copyWith(paymentStatus: selectedStatus!),
                  );
                  if (mounted) setState(() => _order = updated);
                  _showSnackBar(
                    'Payment status updated to ${selectedStatus![0].toUpperCase()}${selectedStatus!.substring(1)}',
                  );
                } else {
                  _showSnackBar(viewModel.state.errorMessage!, isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
