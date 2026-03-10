import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '../view_model/cart_view_model.dart';
import '../widgets/cart_item_widget.dart';
import '../../domain/models/cart_item.dart';
import '../../../order/presentation/pages/customer/checkout_page.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  /// productIds of items selected for checkout
  final Set<String> _selectedIds = {};
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    // Pre-select all items once cart loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = CartProvider.instance.state.items;
      if (mounted) {
        setState(() {
          _selectedIds.addAll(items.map((i) => i.productId));
          _selectAll = true;
        });
      }
    });
  }

  void _syncSelectAll(List<CartItem> items) {
    if (items.isEmpty) return;
    _selectAll = items.every((i) => _selectedIds.contains(i.productId));
  }

  double _selectedTotal(List<CartItem> items) => items
      .where((i) => _selectedIds.contains(i.productId))
      .fold(0, (sum, i) => sum + i.priceAtTime * i.quantity);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: CartProvider.instance,
      child: Consumer<CartViewModel>(
        builder: (context, viewModel, child) {
          final cartState = viewModel.state;
          // When items change (e.g. after remove), keep selection consistent
          _selectedIds.retainWhere(
            (id) => cartState.items.any((i) => i.productId == id),
          );
          _syncSelectAll(cartState.items);

          final selectedItems = cartState.items
              .where((i) => _selectedIds.contains(i.productId))
              .toList();
          final selectedTotal = _selectedTotal(cartState.items);

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Cart'),
              actions: [
                if (cartState.items.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Cart'),
                          content: const Text(
                            'Are you sure you want to remove all items from your cart?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        viewModel.clearCart();
                        setState(() => _selectedIds.clear());
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cart cleared successfully'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
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
                      if (cartState.isLoading) const LinearProgressIndicator(),

                      // Select-all bar
                      Container(
                        color: AppColors.surfaceLight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _selectAll,
                              tristate: true,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.addAll(
                                      cartState.items.map((i) => i.productId),
                                    );
                                    _selectAll = true;
                                  } else {
                                    _selectedIds.clear();
                                    _selectAll = false;
                                  }
                                });
                              },
                            ),
                            Text(
                              'Select All (${cartState.items.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_selectedIds.length} selected',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: cartState.items.length,
                          itemBuilder: (context, index) {
                            final item = cartState.items[index];
                            return CartItemWidget(
                              item: item,
                              isSelected: _selectedIds.contains(item.productId),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(item.productId);
                                  } else {
                                    _selectedIds.remove(item.productId);
                                  }
                                  _syncSelectAll(cartState.items);
                                });
                              },
                            );
                          },
                        ),
                      ),
                      _CartSummary(
                        total: selectedTotal,
                        selectedCount: selectedItems.length,
                        selectedItems: selectedItems,
                      ),
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
  final int selectedCount;
  final List<CartItem> selectedItems;

  const _CartSummary({
    required this.total,
    required this.selectedCount,
    required this.selectedItems,
  });

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
              Text(
                '$selectedCount ${selectedCount == 1 ? 'item' : 'items'} selected',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
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
            onPressed: selectedCount == 0
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CheckoutPage(selectedItems: selectedItems),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              selectedCount == 0 ? 'Select Items' : 'Checkout ($selectedCount)',
            ),
          ),
        ],
      ),
    );
  }
}
