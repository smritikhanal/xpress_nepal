import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/category/presentation/providers/category_provider.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';
import 'package:xpress_nepal/core/utils/image_helper.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
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

  final List<String> _recentSearches = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
  ];

  final List<Map<String, dynamic>> _popularCategories = [
    {'name': 'Electronics', 'icon': Icons.devices_rounded},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'name': 'Home & Garden', 'icon': Icons.home_rounded},
    {'name': 'Sports', 'icon': Icons.sports_basketball_rounded},
    {'name': 'Beauty', 'icon': Icons.face_rounded},
    {'name': 'Toys', 'icon': Icons.toys_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _categoryViewModel.loadCategories();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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

    setState(() {
      _searchController.text = trimmed;
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryId != null ? trimmed : null;
      _hasSearched = true;
    });

    _performSearch(refresh: true);
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

  void _clearRecentSearches() {
    if (_recentSearches.isEmpty) return;

    setState(() {
      _recentSearches.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Recent searches cleared')));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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
          // Search Bar
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
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
                  _buildSortChip('Popular', 'popular'),
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                      _selectedCategoryName = null;
                    });
                    _searchController.text = search;
                    _performSearch();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          search,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Categories
          const Text(
            'Popular Categories',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _popularCategories.length,
            itemBuilder: (context, index) {
              final category = _popularCategories[index];
              return GestureDetector(
                onTap: () {
                  _searchByCategoryName(category['name'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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

        return Column(
          children: [
            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.products.length} results found',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount:
                    state.products.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              ImageHelper.fixImageUrl(product.images.first),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported_rounded,
                                size: 48,
                                color: AppColors.textHint,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_rounded,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Rs. ${displayPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Rs. ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
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
