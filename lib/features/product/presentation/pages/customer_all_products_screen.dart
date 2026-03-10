import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/widgets/product_grid.dart';

/// Generic "View All" screen for any product section on the customer home page.
/// Pass a [filterFn] to filter/sort all products for the specific section.
class CustomerAllProductsScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Applied to the full product list to get the displayed subset.
  final List<ProductEntity> Function(List<ProductEntity>) filterFn;

  const CustomerAllProductsScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.filterFn,
  });

  @override
  State<CustomerAllProductsScreen> createState() =>
      _CustomerAllProductsScreenState();
}

class _CustomerAllProductsScreenState extends State<CustomerAllProductsScreen> {
  late final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _productViewModel.addListener(_onStateChange);
    if (_productViewModel.state.products.isEmpty) {
      _productViewModel.loadProducts(refresh: true);
    }
  }

  @override
  void dispose() {
    _productViewModel.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = _productViewModel.state;
    final products = widget.filterFn(state.products);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final isDesktop = screenWidth >= 1024;
    final crossAxisCount = isDesktop
        ? 4
        : isTablet
        ? 3
        : 2;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(state, products, crossAxisCount, isTablet),
    );
  }

  Widget _buildBody(
    ProductState state,
    List<ProductEntity> products,
    int crossAxisCount,
    bool isTablet,
  ) {
    if (state.status == ProductStatus.loading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ProductStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Failed to load products',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _productViewModel.loadProducts(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 0.72 : 0.68,
      ),
      itemBuilder: (context, index) =>
          ProductCardFromEntity(product: products[index]),
    );
  }
}
