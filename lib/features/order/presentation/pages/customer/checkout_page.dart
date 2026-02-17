import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../addresses/presentation/providers/address_provider.dart';
import '../../../../addresses/presentation/view_model/address_view_model.dart';
import '../../../../cart/presentation/provider/cart_provider.dart';
import '../../../../cart/presentation/view_model/cart_view_model.dart';
import '../../providers/order_provider.dart';
import '../../state/order_state.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

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
  final List<DateTime> _predefinedDates = [
    DateTime(2026, 1, 2),
    DateTime(2026, 1, 3),
    DateTime(2026, 1, 4),
  ];
  final List<String> _timeSlots = [
    'morning',
    'afternoon',
    'evening',
  ];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading checkout: $e')),
        );
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
        const SnackBar(content: Text('Please select delivery date and time slot')),
      );
      return;
    }
    setState(() => _isLoading = true);

    await OrderProvider.instance.createOrder(
      shippingAddressId: _selectedAddressId!,
      paymentMethod: _paymentMethod,
      deliveryDate: _selectedDeliveryDate,
      deliveryTimeSlot: _selectedTimeSlot,
      onSuccess: () {
        setState(() => _isLoading = false);
        CartProvider.instance.clearCart(); // Refresh cart to empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );

    if (mounted && OrderProvider.instance.state.status == OrderStatus.error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${OrderProvider.instance.state.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDependenciesReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
              const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Consumer<AddressViewModel>( 
                 builder: (context, viewModel, __) {
                   final state = viewModel.state;
                   
                   if (state.addresses.isEmpty) {
                     return const Text('No addresses found. Please add one.');
                   }

                   return Column(
                     children: state.addresses.map((addr) {
                       return RadioListTile<String>(
                         value: addr.id,
                         groupValue: _selectedAddressId,
                         onChanged: (val) => setState(() => _selectedAddressId = val),
                         title: Text(addr.fullName),
                         subtitle: Text('${addr.street}, ${addr.city}'),
                         secondary: const Icon(Icons.location_on),
                       );
                     }).toList(),
                   );
                 },
              ),
              const SizedBox(height: 24),
              const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile(
                value: 'cash_on_delivery',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                title: const Text('Cash on Delivery'),
                secondary: const Icon(Icons.money),
              ),
              RadioListTile(
                value: 'khalti',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                title: const Text('Khalti'),
                secondary: const Icon(Icons.account_balance_wallet),
              ),
              RadioListTile(
                value: 'esewa',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                title: const Text('eSewa'),
                secondary: const Icon(Icons.account_balance_wallet_outlined),
              ),
              const SizedBox(height: 24),
              const Text('Delivery Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._predefinedDates.map((date) => RadioListTile<DateTime>(
                    value: date,
                    groupValue: _selectedDeliveryDate,
                    onChanged: (val) => setState(() => _selectedDeliveryDate = val),
                    title: Text('${date.toLocal()}'.split(' ')[0]),
                    secondary: const Icon(Icons.calendar_today),
                  )),
              const SizedBox(height: 16),
              const Text('Delivery Time Slot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._timeSlots.map((slot) => RadioListTile<String>(
                    value: slot,
                    groupValue: _selectedTimeSlot,
                    onChanged: (val) => setState(() => _selectedTimeSlot = val),
                    title: Text(slot[0].toUpperCase() + slot.substring(1)),
                    secondary: const Icon(Icons.access_time),
                  )),
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
    return Consumer<CartViewModel>(
      builder: (context, cart, child) {
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
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('Rs. ${cart.state.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery Fee'),
                  const Text('Rs. 0.00'), // Replace with actual logic if needed
                ],
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
                    'Rs. ${cart.state.totalPrice.toStringAsFixed(2)}',
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
      },
    );
  }
}
