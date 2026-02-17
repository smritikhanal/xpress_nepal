import 'package:xpress_nepal/features/product/presentation/providers/product_reviews_provider.dart';
import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/cart/presentation/provider/cart_provider.dart';
import '../../../../features/cart/presentation/pages/cart_page.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:xpress_nepal/features/messages/presentation/pages/compose_message_page.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';

class CustomerProductDetailScreen extends StatefulWidget {
  final String productId;
  final ProductEntity?
  product; // Optional: pass product directly to avoid re-fetch

  const CustomerProductDetailScreen({
    super.key,
    required this.productId,
    this.product,
  });

  @override
  State<CustomerProductDetailScreen> createState() =>
      _CustomerProductDetailScreenState();
}

class _CustomerProductDetailScreenState
    extends State<CustomerProductDetailScreen> {
  late final ProductReviewsProvider _reviewsProvider;
  final _productViewModel = ProductProvider.instance.productViewModel;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  final Map<String, AttributeOption> _selectedAttributes = {};

  ProductEntity? get _product =>
      widget.product ?? _productViewModel.state.selectedProduct;

  double get _currentPrice {
    final product = _product;
    if (product == null) return 0;

    double price = product.discountPrice ?? product.price;

    // Add attribute modifiers
    for (var option in _selectedAttributes.values) {
      price += option.priceModifier;
    }

    return price;
  }

  @override
  void initState() {
    super.initState();
    _reviewsProvider = ProductReviewsProvider();
    if (widget.product == null) {
      _productViewModel.addListener(_onStateChange);
      _productViewModel.getProductDetails(widget.productId);
    }
    _reviewsProvider.fetchReviews(widget.productId);
  }

  @override
  void dispose() {
    _reviewsProvider.dispose();
    if (widget.product == null) {
      _productViewModel.removeListener(_onStateChange);
    }
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _addToCart() async {
    final product = _product;
    if (product == null) return;

    try {
      await CartProvider.instance.addToCart(
        product.id,
        _currentPrice,
        selectedAttributes: _selectedAttributes.map(
          (key, value) => MapEntry(key, value.value),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity x ${product.title} to cart'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              // Dismiss the snackbar before navigating
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleWishlist() {
    final product = _product;
    if (product == null) return;
    final provider = Provider.of<WishlistProvider>(context, listen: false);
    provider.toggleWishlist(product);
    final isNowWishlisted = provider.isWishlisted(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowWishlisted ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        backgroundColor: isNowWishlisted
            ? AppColors.primary
            : AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _contactSeller(ProductEntity product) {
    final authViewModel = AuthProvider.instance.authViewModel;
    final currentUser = authViewModel.state.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to contact seller'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComposeMessagePage(
          receiverId: product.sellerId,
          receiverName: 'Seller',
          productId: product.id,
          productTitle: product.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If product was passed directly, use it
    if (widget.product != null) {
      return _buildContentWithWishlist(widget.product!);
    }

    // Otherwise, listen to ViewModel state
    final state = _productViewModel.state;

    if (state.status == ProductStatus.loading && _product == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == ProductStatus.error) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Error loading product',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    _productViewModel.getProductDetails(widget.productId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product;
    if (product == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }

    return _buildContentWithWishlist(product);
  }

  Widget _buildContentWithWishlist(ProductEntity product) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        final isWishlisted = wishlistProvider.isWishlisted(product);
        final hasDiscount =
            product.discountPrice != null &&
            product.discountPrice! < product.price;
        final displayPrice = hasDiscount
            ? product.discountPrice!
            : product.price;
        final discountPercent = hasDiscount
            ? ((1 - product.discountPrice! / product.price) * 100).round()
            : 0;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery
                      _buildImageGallery(product),

                      // Product Info
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Wishlist
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
                                  IconButton(
                                    onPressed: () => wishlistProvider
                                        .toggleWishlist(product),
                                    icon: Icon(
                                      isWishlisted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isWishlisted
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              if (product.brand != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  product.brand!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    final rating = product.ratingAvg;
                                    if (index < rating.floor()) {
                                      return const Icon(
                                        Icons.star,
                                        size: 20,
                                        color: Colors.amber,
                                      );
                                    } else if (index < rating) {
                                      return const Icon(
                                        Icons.star_half,
                                        size: 20,
                                        color: Colors.amber,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.star_border,
                                        size: 20,
                                        color: Colors.amber,
                                      );
                                    }
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${product.ratingCount})',
                                    style: TextStyle(color: AppColors.textHint),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text(
                                    'Rs. ${_currentPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (hasDiscount &&
                                      _selectedAttributes.isEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rs. ${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textHint,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    // Hide discount tag if attributes modified price to avoid confusion
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '-$discountPercent%',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (product.description.isNotEmpty) ...[
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.description,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (product.attributes != null)
                                _buildAttributes(product.attributes!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildReviewsSection(),
              ),
              const SizedBox(height: 24),
              _buildBottomBar(product),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Share product
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.share, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImageGallery(ProductEntity product) {
    final images = product.images.isNotEmpty
        ? product.images
        : ['placeholder']; // Fallback

    return Container(
      color: AppColors.surfaceLight,
      child: Column(
        children: [
          // Main Image
          SizedBox(
            height: 350,
            width: double.infinity,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _selectedImageIndex = index);
              },
              itemBuilder: (context, index) {
                final image = images[index];
                if (image == 'placeholder') {
                  return Container(
                    color: AppColors.surfaceLight,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 100,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  );
                }
                return Image.network(
                  ImageHelper.fixImageUrl(image),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceLight,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 100,
                        color: AppColors.textHint,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Image Indicators
          if (images.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _selectedImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _selectedImageIndex == index
                        ? AppColors.primary
                        : AppColors.textHint.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildAttributes(ProductAttributesEntity attributes) {
    if ((attributes.color == null || attributes.color!.isEmpty) &&
        (attributes.size == null || attributes.size!.isEmpty) &&
        (attributes.weight == null || attributes.weight!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (attributes.color != null && attributes.color!.isNotEmpty)
            _buildAttributeSelector('Color', attributes.color!, 'color'),
          if (attributes.size != null && attributes.size!.isNotEmpty)
            _buildAttributeSelector('Size', attributes.size!, 'size'),
          if (attributes.weight != null && attributes.weight!.isNotEmpty)
            _buildAttributeSelector('Weight', attributes.weight!, 'weight'),
        ],
      ),
    );
  }

  Widget _buildAttributeSelector(
    String label,
    List<AttributeOption> options,
    String key,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = _selectedAttributes[key]?.value == option.value;
            String priceText = '';
            if (option.priceModifier != 0) {
              final sign = option.priceModifier > 0 ? '+' : '';
              priceText = ' ($sign${option.priceModifier.toStringAsFixed(0)})';
            }

            return ChoiceChip(
              label: Text('${option.value}$priceText'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAttributes[key] = option;
                  } else {
                    _selectedAttributes.remove(key);
                  }
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBottomBar(ProductEntity product) {
    final isOutOfStock = product.stock <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.surfaceLight, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove, size: 20),
                    color: AppColors.textPrimary,
                    disabledColor: AppColors.textHint,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity < product.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add, size: 20),
                    color: AppColors.textPrimary,
                    disabledColor: AppColors.textHint,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Contact Seller Button
            OutlinedButton(
              onPressed: () => _contactSeller(product),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.message_outlined, size: 22),
            ),

            const SizedBox(width: 12),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: isOutOfStock ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textHint,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOutOfStock
                          ? Icons.remove_shopping_cart
                          : Icons.add_shopping_cart,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return AnimatedBuilder(
      animation: _reviewsProvider,
      builder: (context, _) {
        final reviews = _reviewsProvider.state.reviews;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton.icon(
                  onPressed: _showReviewDialog,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Write a Review'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_reviewsProvider.state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_reviewsProvider.state.error != null)
              Text(
                'Error: ${_reviewsProvider.state.error}',
                style: TextStyle(color: AppColors.error),
              )
            else if (reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No reviews yet. Be the first to review!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ...reviews.map((review) => _buildReviewTile(review)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildReviewTile(ReviewEntity review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            review.rating.toString(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(review.comment),
        subtitle: Text(
          review.userId,
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ),
    );
  }

  void _showReviewDialog() {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Write a Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => rating = index + 1),
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Share your thoughts...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.trim().isEmpty) return;

                  Navigator.pop(context); // Close dialog

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    await _productViewModel.submitReview(
                      productId: widget.productId,
                      rating: rating,
                      comment: commentController.text,
                    );

                    if (!mounted) return;
                    Navigator.pop(context); // Close loading

                    _reviewsProvider.fetchReviews(widget.productId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review submitted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pop(context); // Close loading

                    // Extract message from exception string if possible
                    String errorMessage = e.toString().replaceAll(
                      'Exception: ',
                      '',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
