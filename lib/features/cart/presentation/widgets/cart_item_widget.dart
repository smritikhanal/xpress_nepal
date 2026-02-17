import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/cart_item.dart';
import '../provider/cart_provider.dart';
import '../view_model/cart_view_model.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CartViewModel>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: item.productImage != null
                    ? DecorationImage(
                        image: NetworkImage(item.productImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.productImage == null
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.selectedAttributes != null && item.selectedAttributes!.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: item.selectedAttributes!.entries.map((e) {
                        return Text(
                          '${e.key}: ${e.value}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text('Rs. ${item.priceAtTime.toStringAsFixed(2)}'),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.removeFromCart(item.productId);
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (item.quantity > 1) {
                          viewModel.updateQuantity(item.productId, item.quantity - 1);
                        }
                      },
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        viewModel.updateQuantity(item.productId, item.quantity + 1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
