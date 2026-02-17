import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../view_model/order_view_model.dart';
import '../../state/order_state.dart';
import '../../widgets/order_card.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderProvider.instance.getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: OrderProvider.instance,
      child: Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: Consumer<OrderViewModel>(
          builder: (context, viewModel, child) {
            final state = viewModel.state;

            if (state.status == OrderStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }

            if (state.orders.isEmpty) {
              return const Center(child: Text('No orders found'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await viewModel.getMyOrders();
              },
              child: ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return OrderCard(
                    order: order,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: order),
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
