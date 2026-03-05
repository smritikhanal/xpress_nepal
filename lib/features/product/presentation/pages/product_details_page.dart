import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/pages/edit_product_page.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _productViewModel.getProductDetails(widget.productId);
  }

  void _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _productViewModel.deleteProduct(widget.productId);
      if (success && mounted) {
        Navigator.pop(context); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product deleted successfully'),
            backgroundColor: AppColors.sellerPrimary,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.4,
              right: 8,
              bottom: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: AppColors.sellerPrimaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductPage(
                    product: _productViewModel.state.selectedProduct!,
                  ),
                ),
              ).then(
                (_) => _productViewModel.getProductDetails(widget.productId),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _productViewModel,
        builder: (context, child) {
          final state = _productViewModel.state;

          if (state.status == ProductStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProductStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'Error loading details'),
            );
          }

          final product = state.selectedProduct;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    image: product.images.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              ImageHelper.fixImageUrl(product.images.first),
                            ),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: product.images.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                        )
                      : null,
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: product.isActive
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: product.isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (product.discountPrice != null &&
                          product.discountPrice! > 0 &&
                          product.discountPrice! < product.price) ...[
                        Text(
                          'Rs. ${product.discountPrice}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sellerPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Rs. ${product.price}',
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.textPrimary,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rs. ${(product.price - product.discountPrice!).toStringAsFixed(0)} off',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          'Rs. ${product.price}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sellerPrimary,
                          ),
                        ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Description'),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Inventory & Brand'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoTile('Stock', '${product.stock}'),
                          _buildInfoTile('Brand', product.brand ?? 'N/A'),
                          _buildInfoTile(
                            'Category',
                            product.categoryId.substring(0, 8),
                          ), // Truncated ID
                        ],
                      ),

                      if (product.attributes != null)
                        _buildAttributesSection(product.attributes!),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttributesSection(ProductAttributesEntity attributes) {
    final hasColor = attributes.color != null && attributes.color!.isNotEmpty;
    final hasSize = attributes.size != null && attributes.size!.isNotEmpty;
    final hasWeight =
        attributes.weight != null && attributes.weight!.isNotEmpty;

    if (!hasColor && !hasSize && !hasWeight) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionTitle('Attributes & Variants'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasColor) _buildAttributeRow('Color', attributes.color!),
              if (hasSize) _buildAttributeRow('Size', attributes.size!),
              if (hasWeight) _buildAttributeRow('Weight', attributes.weight!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeRow(String label, List<AttributeOption> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: options.map((option) {
              final priceInfo = option.priceModifier != 0
                  ? ' (${option.priceModifier > 0 ? '+' : ''}Rs. ${option.priceModifier.toStringAsFixed(0)})'
                  : '';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sellerPrimary.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.sellerPrimary.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${option.value}$priceInfo',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.sellerPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textHint),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
