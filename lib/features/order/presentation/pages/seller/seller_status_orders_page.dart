import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../state/order_state.dart';
import '../../view_model/order_view_model.dart';
import '../../widgets/order_card.dart';
import 'seller_order_detail_page.dart';

class SellerStatusOrdersPage extends StatelessWidget {
  /// e.g. 'delivered', 'shipped', 'placed', etc. Pass null to show all orders.
  final String? filterStatus;
  final String title;

  const SellerStatusOrdersPage({
    super.key,
    required this.title,
    this.filterStatus,
  });

  Color _headerColor() {
    switch (filterStatus?.toLowerCase()) {
      case 'placed':
        return const Color(0xFF6C63FF);
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return AppColors.sellerPrimary;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return AppColors.sellerPrimary;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.sellerPrimary;
    }
  }

  IconData _headerIcon() {
    switch (filterStatus?.toLowerCase()) {
      case 'placed':
        return Icons.receipt_long_rounded;
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      case 'processing':
        return Icons.sync_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: OrderProvider.instance,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: _headerColor(),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<OrderViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.state;

            if (state.status == OrderStatus.loading &&
                state.sellerOrders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final filtered = filterStatus == null
                ? state.sellerOrders
                : state.sellerOrders
                      .where(
                        (o) =>
                            o.orderStatus.toLowerCase() ==
                            filterStatus!.toLowerCase(),
                      )
                      .toList();

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _headerIcon(),
                      size: 72,
                      color: _headerColor().withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No $title orders',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Orders with this status will appear here.',
                      style: TextStyle(fontSize: 13, color: AppColors.textHint),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Summary banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: _headerColor().withOpacity(0.08),
                  child: Row(
                    children: [
                      Icon(_headerIcon(), color: _headerColor(), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} order${filtered.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _headerColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => viewModel.getSellerOrders(),
                    color: _headerColor(),
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return OrderCard(
                          order: order,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: viewModel,
                                  child: SellerOrderDetailPage(order: order),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
