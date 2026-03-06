import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../addresses/presentation/pages/add_address_screen.dart';
import '../../../../addresses/presentation/providers/address_provider.dart';
import '../../../../addresses/presentation/view_model/address_view_model.dart';
import '../../../../cart/domain/models/cart_item.dart';
import '../../../../cart/presentation/provider/cart_provider.dart';
import '../../../../cart/presentation/view_model/cart_view_model.dart';
import '../../providers/order_provider.dart';
import '../../state/order_state.dart';

class CheckoutPage extends StatefulWidget {
  /// The cart items the user chose to checkout. If null, all cart items are used.
  final List<CartItem>? selectedItems;

  const CheckoutPage({super.key, this.selectedItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _selectedAddressId;
  String _paymentMethod = 'cash_on_delivery';
  bool _isDependenciesReady = false;
  bool _isLoading = false;
  // Add delivery date and time slot selection
  DateTime? _selectedDeliveryDate;
  String? _selectedTimeSlot;

  static const List<Map<String, String>> _timeSlots = [
    {'value': 'morning', 'label': 'Morning', 'hours': '6:00 AM – 11:00 AM'},
    {'value': 'afternoon', 'label': 'Afternoon', 'hours': '11:00 AM – 4:00 PM'},
    {'value': 'evening', 'label': 'Evening', 'hours': '4:00 PM – 9:00 PM'},
  ];

  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate ?? firstDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'SELECT DELIVERY DATE',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFFF6B35),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDeliveryDate = picked);
    }
  }

  late final AddressViewModel _addressViewModel;
  late final CartViewModel _cartViewModel;

  @override
  void initState() {
    super.initState();
    _initDependencies();
  }

  Future<void> _initDependencies() async {
    try {
      await AddressProvider.instance.initialize();
      _addressViewModel = AddressProvider.instance.addressViewModel;
      _cartViewModel = CartProvider.instance; // Initialize CartViewModel here

      // Safe to access addressViewModel now
      await _addressViewModel.fetchAddresses();

      if (mounted) {
        setState(() {
          _isDependenciesReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing dependencies: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading checkout: $e')));
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address')),
      );
      return;
    }

    if (_selectedDeliveryDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select delivery date and time slot'),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    await OrderProvider.instance.createOrder(
      shippingAddressId: _selectedAddressId!,
      paymentMethod: _paymentMethod,
      deliveryDate: _selectedDeliveryDate,
      deliveryTimeSlot: _selectedTimeSlot,
      selectedProductIds: widget.selectedItems
          ?.map((i) => i.productId)
          .toList(),
      onSuccess: () {
        setState(() => _isLoading = false);
        // Remove only the purchased items; leave other cart items intact
        if (widget.selectedItems != null) {
          final cartItemIds = CartProvider.instance.state.items
              .map((i) => i.productId)
              .toSet();
          for (final item in widget.selectedItems!) {
            if (cartItemIds.contains(item.productId)) {
              CartProvider.instance.removeFromCart(item.productId);
            }
          }
        } else {
          CartProvider.instance.clearCart();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );

    if (mounted && OrderProvider.instance.state.status == OrderStatus.error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${OrderProvider.instance.state.errorMessage}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDependenciesReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _addressViewModel),
        ChangeNotifierProvider.value(value: _cartViewModel),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(context),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shipping Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAddressScreen(),
                        ),
                      );
                      if (mounted) {
                        await _addressViewModel.fetchAddresses();
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add New'),
                  ),
                ],
              ),
              Consumer<AddressViewModel>(
                builder: (context, viewModel, __) {
                  final state = viewModel.state;

                  if (state.addresses.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddAddressScreen(),
                            ),
                          );
                          if (mounted) {
                            await _addressViewModel.fetchAddresses();
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Add a Shipping Address'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: state.addresses.map((addr) {
                      return RadioListTile<String>(
                        value: addr.id,
                        groupValue: _selectedAddressId,
                        onChanged: (val) =>
                            setState(() => _selectedAddressId = val),
                        title: Text(addr.fullName),
                        subtitle: Text('${addr.street}, ${addr.city}'),
                        secondary: const Icon(Icons.location_on),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                value: 'cash_on_delivery',
                groupValue: _paymentMethod,
                onChanged: (val) =>
                    setState(() => _paymentMethod = val.toString()),
                title: const Text('Cash on Delivery'),
                secondary: const Icon(Icons.money),
              ),
              RadioListTile(
                value: 'khalti',
                groupValue: _paymentMethod,
                onChanged: (val) =>
                    setState(() => _paymentMethod = val.toString()),
                title: const Text('Khalti'),
                secondary: const Icon(Icons.account_balance_wallet),
              ),
              RadioListTile(
                value: 'esewa',
                groupValue: _paymentMethod,
                onChanged: (val) =>
                    setState(() => _paymentMethod = val.toString()),
                title: const Text('eSewa'),
                secondary: const Icon(Icons.account_balance_wallet_outlined),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delivery Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDeliveryDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedDeliveryDate != null
                          ? const Color(0xFFFF6B35)
                          : Colors.grey.shade300,
                      width: _selectedDeliveryDate != null ? 1.8 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedDeliveryDate != null
                        ? const Color(0xFFFFF3EE)
                        : Theme.of(context).cardColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: _selectedDeliveryDate != null
                            ? const Color(0xFFFF6B35)
                            : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDeliveryDate != null
                              ? '${_selectedDeliveryDate!.day} '
                                    '${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][_selectedDeliveryDate!.month - 1]} '
                                    '${_selectedDeliveryDate!.year}'
                              : 'Tap to choose a date',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _selectedDeliveryDate != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _selectedDeliveryDate != null
                                ? const Color(0xFFFF6B35)
                                : Colors.grey,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: _selectedDeliveryDate != null
                            ? const Color(0xFFFF6B35)
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delivery Time Slot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...(_timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot['value'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedTimeSlot = slot['value']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : Colors.grey.shade300,
                        width: isSelected ? 1.8 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? const Color(0xFFFFF3EE)
                          : Theme.of(context).cardColor,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6B35).withOpacity(0.15)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slot['value'] == 'morning'
                                ? Icons.wb_sunny_rounded
                                : slot['value'] == 'afternoon'
                                ? Icons.wb_cloudy_rounded
                                : Icons.nights_stay_rounded,
                            size: 18,
                            color: isSelected
                                ? const Color(0xFFFF6B35)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot['label']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFFF6B35)
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                slot['hours']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? const Color(0xFFFF6B35).withOpacity(0.8)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFFFF6B35),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              })),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Place Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    // If specific items were selected, show only those; otherwise fall back to full cart
    if (widget.selectedItems != null) {
      final items = widget.selectedItems!;
      final subtotal = items.fold<double>(
        0,
        (sum, i) => sum + i.priceAtTime * i.quantity,
      );
      return _buildSummaryCard(
        context: context,
        subtotal: subtotal,
        itemCount: items.length,
      );
    }

    return Consumer<CartViewModel>(
      builder: (context, cart, child) {
        return _buildSummaryCard(
          context: context,
          subtotal: cart.state.totalPrice,
          itemCount: cart.state.items.length,
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required double subtotal,
    required int itemCount,
  }) {
    const double deliveryFee = 100.0;
    final double total = subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('Rs. ${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('Delivery Fee'), const Text('Rs. 100.00')],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs. ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
