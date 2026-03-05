import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';
import 'package:xpress_nepal/features/product/presentation/pages/customer_product_detail_screen.dart';

class SellerAllReviewsScreen extends StatefulWidget {
  final String sellerId;
  const SellerAllReviewsScreen({Key? key, required this.sellerId})
    : super(key: key);

  @override
  State<SellerAllReviewsScreen> createState() => _SellerAllReviewsScreenState();
}

class _SellerAllReviewsScreenState extends State<SellerAllReviewsScreen> {
  final _productViewModel = ProductProvider.instance.productViewModel;

  List<_ReviewWithProduct> _allReviews = [];
  List<_ReviewWithProduct> _filteredReviews = [];
  bool _isLoading = true;
  String? _error;
  int _selectedRatingFilter = 0; // 0 = All

  @override
  void initState() {
    super.initState();
    _loadAllReviews();
  }

  Future<void> _loadAllReviews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = _productViewModel.state.products
          .where((p) => p.sellerId == widget.sellerId)
          .toList();
      final List<_ReviewWithProduct> all = [];
      for (final product in products) {
        final reviews = await _productViewModel.fetchProductReviews(product.id);
        for (final r in reviews) {
          all.add(_ReviewWithProduct(review: r, product: product));
        }
      }
      all.sort((a, b) {
        final aDate = a.review.createdAt ?? '';
        final bDate = b.review.createdAt ?? '';
        return bDate.compareTo(aDate);
      });
      if (mounted) {
        setState(() {
          _allReviews = all;
          _filteredReviews = all;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
    }
  }

  void _applyFilter(int rating) {
    setState(() {
      _selectedRatingFilter = rating;
      _filteredReviews = rating == 0
          ? _allReviews
          : _allReviews.where((r) => r.review.rating == rating).toList();
    });
  }

  double get _averageRating {
    if (_allReviews.isEmpty) return 0;
    final sum = _allReviews.fold<int>(0, (s, r) => s + r.review.rating);
    return sum / _allReviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _allReviews) {
      final stars = r.review.rating.clamp(1, 5);
      map[stars] = (map[stars] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _buildError()
                  : _allReviews.isEmpty
                  ? _buildEmpty()
                  : Column(
                      children: [
                        _buildSummaryCard(),
                        _buildFilterChips(),
                        Expanded(child: _buildReviewList()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.sellerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Reviews',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Customer feedback on your products',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final avg = _averageRating;
    final dist = _ratingDistribution;
    final total = _allReviews.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Average rating big display
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < avg.round()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total reviews',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Rating bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = dist[star] ?? 0;
                final fraction = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction.toDouble(),
                            backgroundColor: AppColors.borderLight,
                            color: Colors.amber,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final labels = {0: 'All', 5: '5★', 4: '4★', 3: '3★', 2: '2★', 1: '1★'};
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: labels.entries.map((e) {
          final selected = _selectedRatingFilter == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(e.value),
              selected: selected,
              onSelected: (_) => _applyFilter(e.key),
              selectedColor: AppColors.sellerPrimaryLight,
              checkmarkColor: AppColors.sellerPrimaryDark,
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.sellerPrimaryDark
                    : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: selected
                    ? AppColors.sellerPrimary
                    : AppColors.borderLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewList() {
    if (_filteredReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star_border_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              'No $_selectedRatingFilter-star reviews',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _filteredReviews.length,
      itemBuilder: (context, index) =>
          _buildReviewCard(_filteredReviews[index]),
    );
  }

  Widget _buildReviewCard(_ReviewWithProduct item) {
    final r = item.review;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerProductDetailScreen(
            productId: item.product.id,
            product: item.product,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.sellerPrimaryLight,
                  child: Text(
                    (r.userName ?? r.userId)[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.sellerPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.userName ?? 'Customer',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item.product.title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${r.rating}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              r.comment,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (r.createdAt != null && r.createdAt!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _formatDate(r.createdAt!),
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to load reviews',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadAllReviews,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border_rounded, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Reviews from customers will appear here.',
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _ReviewWithProduct {
  final ReviewEntity review;
  final ProductEntity product;
  const _ReviewWithProduct({required this.review, required this.product});
}
