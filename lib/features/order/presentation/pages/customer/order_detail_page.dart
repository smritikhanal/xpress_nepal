import 'package:flutter/material.dart';
import '../../../domain/models/order_entity.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${order.id.substring(order.id.length - 8).toUpperCase()}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Status'),
            Text(
              order.orderStatus.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

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
}
