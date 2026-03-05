import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../view_model/order_view_model.dart';
import '../../state/order_state.dart';
import '../../widgets/order_card.dart';
import 'seller_order_detail_page.dart';

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderProvider.instance.getSellerOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: OrderProvider.instance,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Orders'),
          backgroundColor: const Color(0xFF00C462), // AppColors.sellerPrimary
        ),
        body: Consumer<OrderViewModel>(
          builder: (context, viewModel, child) {
            final state = viewModel.state;

            if (state.status == OrderStatus.loading &&
                state.sellerOrders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.sellerOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.getSellerOrders(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.sellerOrders.isEmpty) {
              return const Center(child: Text('No orders found'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await viewModel.getSellerOrders();
              },
              child: ListView.builder(
                itemCount: state.sellerOrders.length,
                itemBuilder: (context, index) {
                  final order = state.sellerOrders[index];
                  return OrderCard(
                    order: order,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: SellerOrderDetailPage(order: order),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
