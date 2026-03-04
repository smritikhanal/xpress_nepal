import 'package:flutter/material.dart';

import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';

class WishlistScreen extends StatelessWidget {
  final List<ProductEntity>? wishlistItems;
  const WishlistScreen({super.key, this.wishlistItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, _) {
          final items = provider.wishlist.isNotEmpty
              ? provider.wishlist
              : (wishlistItems ?? const <ProductEntity>[]);

          if (provider.loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.images.isNotEmpty
                        ? Image.network(
                            ImageHelper.fixImageUrl(item.images.first),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    (item.brand?.trim().isNotEmpty ?? false)
                        ? item.brand!
                        : 'No brand',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
