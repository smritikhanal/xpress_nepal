import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '../view_model/cart_view_model.dart';
import '../widgets/cart_item_widget.dart';
import '../../../order/presentation/pages/customer/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: CartProvider.instance,
      child: Consumer<CartViewModel>(
        builder: (context, viewModel, child) {
          final cartState = viewModel.state;

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Cart'),
              actions: [
                if (cartState.items.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () {
                      viewModel.clearCart();
                    },
                  ),
              ],
            ),
            body: cartState.isLoading && cartState.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : cartState.items.isEmpty
                    ? const Center(child: Text('Your cart is empty'))
                    : Column(
                        children: [
                          if (cartState.error != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Error: ${cartState.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          if (cartState.isLoading)
                            const LinearProgressIndicator(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartState.items.length,
                              itemBuilder: (context, index) {
                                return CartItemWidget(item: cartState.items[index]);
                              },
                            ),
                          ),
                          _CartSummary(total: cartState.totalPrice),
                        ],
                      ),
          );
        },
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  const _CartSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total:', style: TextStyle(color: Colors.grey)),
              Text(
                'Rs. ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
