import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/order_entity.dart';
import '../../view_model/order_view_model.dart';
import 'package:intl/intl.dart';

class SellerOrderDetailPage extends StatelessWidget {
  final OrderEntity order;

  const SellerOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${order.id.substring(order.id.length - 8).toUpperCase()}',
        ),
        backgroundColor: const Color(0xFF00C462),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Customer Info'),
            Text(
              'User ID: ${order.userId}',
            ), // Could fetch user details if needed
            const SizedBox(height: 16),

            _buildSectionTitle('Status'),
            Row(
              children: [
                _buildStatusChip(order.orderStatus),
                const SizedBox(width: 12),
                _buildPaymentStatusChip(order.paymentStatus),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Items'),
            ...order.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                title: Text(item.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.quantity} x Rs. ${item.price}'),
                    if (item.attributes.isNotEmpty)
                      _buildOrderItemAttributes(item.attributes),
                  ],
                ),
                trailing: Text(
                  'Rs. ${(item.quantity * item.price).toStringAsFixed(0)}',
                ),
              ),
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Shipping Address'),
            Text(order.shippingAddress.fullName),
            Text(order.shippingAddress.phone),
            Text(
              '${order.shippingAddress.street}, ${order.shippingAddress.city}',
            ),
            Text(
              '${order.shippingAddress.state}, ${order.shippingAddress.country}',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Payment'),
            Text('Method: ${order.paymentMethod}'),
            Text('Status: ${order.paymentStatus}'),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStatusUpdateDialog(context, order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C462),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Order Status',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemAttributes(Map<String, dynamic> attributes) {
    if (attributes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attributes.entries.map((entry) {
        final attrName = entry.key;
        final attrValue = entry.value;
        if (attrValue is List) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: attrValue.map<Widget>((opt) {
              return Text(
                '$attrName: ${opt['value']} (+${opt['priceModifier'] ?? 0})',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              );
            }).toList(),
          );
        }
        return Text(
          '$attrName: $attrValue',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'placed':
        color = Colors.blue;
        break;
      case 'confirmed':
        color = Colors.purple;
        break;
      case 'shipped':
        color = Colors.orange;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.green;
        break;
      case 'paid':
        color = Colors.green;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, OrderEntity order) {
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    String? selectedOrderStatus = order.orderStatus;
    // Payment status update might be restricted or separate, but including as per previous logic

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Order Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...['confirmed', 'shipped', 'delivered', 'cancelled'].map(
                    (status) => RadioListTile<String>(
                      value: status,
                      groupValue: selectedOrderStatus,
                      activeColor: const Color(0xFF00C462),
                      onChanged: (val) =>
                          setState(() => selectedOrderStatus = val),
                      title: Text(status.toUpperCase()),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedOrderStatus != null) {
                      viewModel.updateOrderStatus(
                        order.id,
                        selectedOrderStatus!,
                      );
                      Navigator.pop(context); // Close dialog
                      // Optionally pop page or refresh
                      // The parent list will refresh when we return if we set it up,
                      // but ideally the ViewModel update should trigger a notifyListeners which updates the UI.
                      // However, this page is static unless we wrap it in Consumer or pass updated order.
                      // For now, closing dialog is enough, the user can go back.
                      // OR we can make this page listen to the specific order.
                      // But simpliest is:
                      Navigator.pop(context); // Go back to list
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
