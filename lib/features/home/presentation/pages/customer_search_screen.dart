import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/cart/presentation/provider/cart_provider.dart';
import 'package:xpress_nepal/features/category/presentation/providers/category_provider.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';
import 'package:provider/provider.dart';

class CustomerSearchScreen extends StatefulWidget {
  final String? initialCategoryName;

  const CustomerSearchScreen({super.key, this.initialCategoryName});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

/// Convenience wrapper for search with pre-selected category
class CustomerSearchScreenWithCategory extends StatelessWidget {
  final String categoryName;

  const CustomerSearchScreenWithCategory({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerSearchScreen(initialCategoryName: categoryName);
  }
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _productViewModel = ProductProvider.instance.productViewModel;
  final _categoryViewModel = CategoryProvider.instance.categoryViewModel;
  final _focusNode = FocusNode();

  String _sortBy = 'newest';
  bool _hasSearched = false;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _pendingCategoryName;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _categoryViewModel.addListener(_onCategoriesChanged);
    _productViewModel.addListener(_onProductsChanged);

    // Load products for category filtering if not already loaded
    if (_productViewModel.state.products.isEmpty) {
      _productViewModel.loadProducts(refresh: true);
    }

    if (widget.initialCategoryName != null) {
      _pendingCategoryName = widget.initialCategoryName;
      _categoryViewModel.loadCategories();
    } else {
      _categoryViewModel.loadCategories();
      // Auto-focus search field if no initial category
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onCategoriesChanged() {
    if (mounted) setState(() {});
    if (_pendingCategoryName != null &&
        !_categoryViewModel.isLoading &&
        _categoryViewModel.categories.isNotEmpty) {
      final pending = _pendingCategoryName!;
      _pendingCategoryName = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchByCategoryName(pending);
      });
    }
  }

  void _onProductsChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_isBottom && !_productViewModel.state.hasReachedMax) {
      _performSearch(refresh: false);
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _performSearch({bool refresh = true}) {
    final query = _searchController.text.trim();
    final effectiveCategoryId = _selectedCategoryId;
    final isCategorySearch =
        effectiveCategoryId != null && effectiveCategoryId.isNotEmpty;

    if (query.isEmpty && !isCategorySearch) return;

    setState(() {
      _hasSearched = true;
    });

    _productViewModel.loadProducts(
      categoryId: isCategorySearch ? effectiveCategoryId : null,
      search: isCategorySearch ? null : query,
      sort: _sortBy,
      refresh: refresh,
    );
  }

  void _searchByCategoryName(String categoryName) {
    final trimmed = categoryName.trim();
    final categories = _categoryViewModel.categories;

    String? categoryId;

    for (final category in categories) {
      if (category.name.toLowerCase() == trimmed.toLowerCase()) {
        categoryId = category.id;
        break;
      }
    }

    if (categoryId == null) {
      for (final category in categories) {
        if (category.name.toLowerCase().contains(trimmed.toLowerCase())) {
          categoryId = category.id;
          break;
        }
      }
    }

    // If categories not loaded yet, store as pending and retry after load
    if (categoryId == null && categories.isEmpty) {
      _pendingCategoryName = trimmed;
      return;
    }

    setState(() {
      _searchController.text = trimmed;
      _selectedCategoryId = categoryId;
      _selectedCategoryName = trimmed;
      _hasSearched = true;
    });

    _productViewModel.loadProducts(
      categoryId: categoryId,
      search: categoryId == null ? trimmed : null,
      sort: _sortBy,
      refresh: true,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _categoryViewModel.removeListener(_onCategoriesChanged);
    _productViewModel.removeListener(_onProductsChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  IconData _resolveCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fashion') || lower.contains('cloth')) {
      return Icons.checkroom_rounded;
    } else if (lower.contains('electronic') ||
        lower.contains('device') ||
        lower.contains('tech')) {
      return Icons.devices_rounded;
    } else if (lower.contains('home') ||
        lower.contains('garden') ||
        lower.contains('furniture')) {
      return Icons.home_rounded;
    } else if (lower.contains('sport') || lower.contains('fitness')) {
      return Icons.sports_basketball_rounded;
    } else if (lower.contains('beauty') ||
        lower.contains('skin') ||
        lower.contains('cosmetic')) {
      return Icons.face_rounded;
    } else if (lower.contains('book') || lower.contains('education')) {
      return Icons.menu_book_rounded;
    } else if (lower.contains('toy') ||
        lower.contains('kid') ||
        lower.contains('child')) {
      return Icons.toys_rounded;
    } else if (lower.contains('food') || lower.contains('grocery')) {
      return Icons.local_grocery_store_rounded;
    } else if (lower.contains('health') || lower.contains('medical')) {
      return Icons.health_and_safety_rounded;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(),

            // Content
            Expanded(
              child: _hasSearched
                  ? _buildSearchResults()
                  : _buildSearchSuggestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final theme = Theme.of(context);
    final canPop = Navigator.canPop(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar row (with optional back button)
          Row(
            children: [
              if (canPop) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.textPrimary,
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search products, brands, categories...',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.65,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: AppColors.textHint,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor:
                        theme.inputDecorationTheme.fillColor ??
                        theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    if (_selectedCategoryId != null &&
                        value.trim().toLowerCase() !=
                            (_selectedCategoryName ?? '').toLowerCase()) {
                      setState(() {
                        _selectedCategoryId = null;
                        _selectedCategoryName = null;
                      });
                    } else {
                      setState(() {});
                    }
                  },
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
            ],
          ),

          // Sort Options (only when searching)
          if (_hasSearched) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Newest', 'newest'),
                  _buildSortChip('Price: Low to High', 'price_asc'),
                  _buildSortChip('Price: High to Low', 'price_desc'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _sortBy = value;
          });
          _performSearch();
        },
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primaryLight,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: AppColors.primary,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Categories — filtered to only those with products
          const Text(
            'Popular Categories',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final allCategories = _categoryViewModel.categories;
              final products = _productViewModel.state.products;

              // Build set of active category names from loaded products
              final activeCategoryNames = products
                  .where(
                    (p) => p.categoryName != null && p.categoryName!.isNotEmpty,
                  )
                  .map((p) => p.categoryName!.toLowerCase().trim())
                  .toSet();

              // Filter to categories that have products (show all if products not loaded yet)
              final visibleCategories = products.isEmpty
                  ? allCategories
                  : allCategories.where((cat) {
                      return activeCategoryNames.contains(
                        cat.name.toLowerCase().trim(),
                      );
                    }).toList();

              if (_categoryViewModel.isLoading && allCategories.isEmpty) {
                return const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (visibleCategories.isEmpty) {
                return const SizedBox.shrink();
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visibleCategories.map((category) {
                  return GestureDetector(
                    onTap: () => _searchByCategoryName(category.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _resolveCategoryIcon(category.name),
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Trending Searches
          const Text(
            'Trending Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(5, (index) {
            final trendingItems = [
              'Wireless Earbuds',
              'Smart Watch',
              'Running Shoes',
              'Organic Skincare',
              'Gaming Accessories',
            ];
            return ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: index < 3
                      ? AppColors.primaryLight
                      : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: index < 3 ? AppColors.primary : AppColors.textHint,
                    ),
                  ),
                ),
              ),
              title: Text(trendingItems[index]),
              trailing: Icon(
                index < 3
                    ? Icons.trending_up_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 18,
                color: index < 3 ? AppColors.success : AppColors.textHint,
              ),
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                  _selectedCategoryName = null;
                });
                _searchController.text = trendingItems[index];
                _performSearch();
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return AnimatedBuilder(
      animation: _productViewModel,
      builder: (context, child) {
        final state = _productViewModel.state;

        if (state.products.isEmpty) {
          if (state.status == ProductStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state.status == ProductStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Error searching products',
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: AppColors.textHint.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results for "${_searchController.text}"',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try different keywords or browse categories',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Search'),
                  ),
                ],
              ),
            );
          }
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth >= 650;
        final crossAxisCount = isTablet ? 3 : 2;

        return Column(
          children: [
            // Results count bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textHint.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.products.length} result${state.products.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'for "${_searchController.text}"',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: isTablet ? 0.68 : 0.63,
                ),
                itemCount:
                    state.products.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: AppColors.sellerPrimary,
                        ),
                      ),
                    );
                  }

                  final product = state.products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final displayPrice = hasDiscount ? product.discountPrice! : product.price;
    final discountPercent = hasDiscount
        ? ((product.price - product.discountPrice!) / product.price * 100)
              .round()
        : 0;
    final hasRating = product.ratingCount > 0;
    final shortDesc = (product.description as String).trim();
    final category = product.categoryName as String?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerProductDetailScreen(
              productId: product.id,
              product: product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────
            SizedBox(
              height: 155,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      color: AppColors.surfaceLight,
                      child: product.images.isNotEmpty
                          ? Image.network(
                              ImageHelper.fixImageUrl(product.images.first),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 40,
                                  color: AppColors.textHint,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_rounded,
                                size: 40,
                                color: AppColors.textHint,
                              ),
                            ),
                    ),
                  ),
                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4444), Color(0xFFFF6B6B)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  // Wishlist button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, _) {
                        final isWishlisted = wishlistProvider.isWishlisted(
                          product,
                        );
                        return GestureDetector(
                          onTap: () => wishlistProvider.toggleWishlist(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).cardColor.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 16,
                              color: isWishlisted
                                  ? AppColors.error
                                  : AppColors.textHint,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Stock out overlay
                  if (product.stock == 0)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Details ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    if (category != null && category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    // Title
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Short description
                    if (shortDesc.isNotEmpty) ...[
                      Text(
                        shortDesc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Rating
                    if (hasRating) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            product.ratingAvg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' (${product.ratingCount})',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    const Spacer(),
                    // Price row + Add button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Rs. ${displayPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  'Rs. ${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textHint,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.textHint,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Add to cart button
                        if (product.stock > 0)
                          GestureDetector(
                            onTap: () {
                              final price =
                                  (product.discountPrice != null &&
                                      product.discountPrice! < product.price)
                                  ? product.discountPrice!
                                  : product.price;
                              CartProvider.instance.addToCart(
                                product.id,
                                price,
                              );
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Added to cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(
                                      left:
                                          MediaQuery.of(context).size.width *
                                          0.45,
                                      bottom: 16,
                                      right: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
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
}
