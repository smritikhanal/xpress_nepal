import 'package:flutter/material.dart';

import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';

class WishlistScreen extends StatelessWidget {
  final List<ProductEntity> wishlistItems;
  const WishlistScreen({Key? key, required this.wishlistItems})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlistItems.isEmpty
          ? const Center(child: Text('Your wishlist is empty.'))
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return ListTile(
                  leading: item.images.isNotEmpty
                      ? Image.network(
                          ImageHelper.fixImageUrl(item.images.first),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(item.title),
                  subtitle: Text(item.brand ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      Provider.of<WishlistProvider>(
                        context,
                        listen: false,
                      ).removeFromWishlist(item);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerProductDetailScreen(
                          productId: item.id,
                          product: item,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
