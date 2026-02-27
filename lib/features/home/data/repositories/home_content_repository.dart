import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Aggregate payload for Home screen sections.
class HomeContentPayload {
  final List<Map<String, dynamic>> banners;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> flashSaleProducts;
  final List<Map<String, dynamic>> trendingProducts;
  final List<Map<String, dynamic>> newArrivals;
  final List<Map<String, dynamic>> deals;
  final List<Map<String, dynamic>> topSellers;
  final bool fromOffline;

  const HomeContentPayload({
    required this.banners,
    required this.categories,
    required this.flashSaleProducts,
    required this.trendingProducts,
    required this.newArrivals,
    required this.deals,
    required this.topSellers,
    required this.fromOffline,
  });
}

/// Repository that provides Home content with online/offline fallback.
class HomeContentRepository {
  HomeContentPayload? _cache;

  Future<HomeContentPayload> fetchHomeContent() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final remoteData = await _fetchRemoteContent();
        _cache = remoteData;
        return remoteData;
      } catch (_) {
        final offlineData = await _fetchLocalContent();
        _cache = offlineData;
        return offlineData;
      }
    }

    final offlineData = await _fetchLocalContent();
    _cache = offlineData;
    return offlineData;
  }

  Future<HomeContentPayload> _fetchRemoteContent() async {
    // Simulate API/network call. Replace with real remote datasource later.
    await Future.delayed(const Duration(milliseconds: 500));

    final random = Random();

    final banners = List<Map<String, dynamic>>.from(_baseBanners)
      ..shuffle(random);
    final trending = List<Map<String, dynamic>>.from(_baseTrendingProducts)
      ..shuffle(random);
    final newArrivals = List<Map<String, dynamic>>.from(_baseNewArrivals)
      ..shuffle(random);

    return HomeContentPayload(
      banners: banners,
      categories: List<Map<String, dynamic>>.from(_baseCategories),
      flashSaleProducts: List<Map<String, dynamic>>.from(
        _baseFlashSaleProducts,
      ),
      trendingProducts: trending,
      newArrivals: newArrivals,
      deals: List<Map<String, dynamic>>.from(_baseDeals),
      topSellers: List<Map<String, dynamic>>.from(_baseTopSellers),
      fromOffline: false,
    );
  }

  Future<HomeContentPayload> _fetchLocalContent() async {
    // Simulate local DB/cache read.
    await Future.delayed(const Duration(milliseconds: 250));

    if (_cache != null) {
      return HomeContentPayload(
        banners: List<Map<String, dynamic>>.from(_cache!.banners),
        categories: List<Map<String, dynamic>>.from(_cache!.categories),
        flashSaleProducts: List<Map<String, dynamic>>.from(
          _cache!.flashSaleProducts,
        ),
        trendingProducts: List<Map<String, dynamic>>.from(
          _cache!.trendingProducts,
        ),
        newArrivals: List<Map<String, dynamic>>.from(_cache!.newArrivals),
        deals: List<Map<String, dynamic>>.from(_cache!.deals),
        topSellers: List<Map<String, dynamic>>.from(_cache!.topSellers),
        fromOffline: true,
      );
    }

    return HomeContentPayload(
      banners: List<Map<String, dynamic>>.from(_baseBanners),
      categories: List<Map<String, dynamic>>.from(_baseCategories),
      flashSaleProducts: List<Map<String, dynamic>>.from(
        _baseFlashSaleProducts,
      ),
      trendingProducts: List<Map<String, dynamic>>.from(_baseTrendingProducts),
      newArrivals: List<Map<String, dynamic>>.from(_baseNewArrivals),
      deals: List<Map<String, dynamic>>.from(_baseDeals),
      topSellers: List<Map<String, dynamic>>.from(_baseTopSellers),
      fromOffline: true,
    );
  }

  static const List<Map<String, dynamic>> _baseBanners = [
    {
      'image': 'assets/images/products/promo1.png',
      'title': 'Super Sale!',
      'subtitle': 'Up to 50% Off on Electronics',
    },
    {
      'image': 'assets/images/products/promo2.webp',
      'title': 'New Arrivals',
      'subtitle': 'Fresh Collection Just Landed',
    },
    {
      'image': 'assets/images/products/promo3.jpg',
      'title': 'Flash Deals',
      'subtitle': 'Limited Time Offers',
    },
  ];

  static const List<Map<String, dynamic>> _baseCategories = [
    {'name': 'Fashion', 'icon': 'checkroom_rounded', 'items': 1234},
    {'name': 'Electronics', 'icon': 'devices_rounded', 'items': 856},
    {'name': 'Home', 'icon': 'home_rounded', 'items': 654},
    {'name': 'Sports', 'icon': 'sports_basketball_rounded', 'items': 432},
    {'name': 'Beauty', 'icon': 'face_rounded', 'items': 567},
    {'name': 'Books', 'icon': 'menu_book_rounded', 'items': 890},
    {'name': 'Toys', 'icon': 'toys_rounded', 'items': 321},
    {'name': 'More', 'icon': 'more_horiz_rounded', 'items': 0},
  ];

  static const List<Map<String, dynamic>> _baseFlashSaleProducts = [
    {
      'name': 'iPhone 15 Pro',
      'originalPrice': 199000,
      'salePrice': 179000,
      'discount': 10,
      'sold': 156,
      'total': 200,
      'image': 'assets/images/products/iphone.jpg',
    },
    {
      'name': 'Samsung Galaxy S24',
      'originalPrice': 95000,
      'salePrice': 85550,
      'discount': 10,
      'sold': 89,
      'total': 150,
      'image': 'assets/images/products/samsung.jpg',
    },
    {
      'name': 'Winter Jacket',
      'originalPrice': 2500,
      'salePrice': 1520,
      'discount': 40,
      'sold': 234,
      'total': 300,
      'image': 'assets/images/products/winterjacket.jpg',
    },
    {
      'name': 'Razer Blade Laptop',
      'originalPrice': 250000,
      'salePrice': 199000,
      'discount': 20,
      'sold': 45,
      'total': 100,
      'image': 'assets/images/products/razerblade.jpg',
    },
  ];

  static const List<Map<String, dynamic>> _baseTrendingProducts = [
    {
      'name': 'iPhone 15 Pro Max',
      'price': 190000,
      'rating': 4.8,
      'reviews': 2341,
      'image': 'assets/images/products/iphone.jpg',
      'isNew': true,
    },
    {
      'name': 'Samsung Galaxy S24',
      'price': 85550,
      'rating': 4.6,
      'reviews': 892,
      'image': 'assets/images/products/samsung.jpg',
      'isNew': false,
    },
    {
      'name': 'Winter Jacket Premium',
      'price': 1520,
      'rating': 4.9,
      'reviews': 1567,
      'image': 'assets/images/products/winterjacket.jpg',
      'isNew': true,
    },
    {
      'name': 'Leather Boots',
      'price': 3500,
      'rating': 4.7,
      'reviews': 723,
      'image': 'assets/images/products/boots.jpg',
      'isNew': false,
    },
    {
      'name': 'Summer Dress',
      'price': 2999,
      'rating': 4.5,
      'reviews': 456,
      'image': 'assets/images/products/dress.jpg',
      'isNew': true,
    },
  ];

  static const List<Map<String, dynamic>> _baseNewArrivals = [
    {
      'name': 'Summer Dress Collection',
      'price': 2999,
      'category': 'Fashion',
      'image': 'assets/images/products/dress.jpg',
      'daysAgo': 1,
    },
    {
      'name': 'Water Bottle Premium',
      'price': 899,
      'category': 'Sports',
      'image': 'assets/images/products/bottle.jpg',
      'daysAgo': 2,
    },
    {
      'name': 'Razer Blade Gaming',
      'price': 199000,
      'category': 'Electronics',
      'image': 'assets/images/products/razerblade.jpg',
      'daysAgo': 3,
    },
    {
      'name': 'Leather Boots Premium',
      'price': 3500,
      'category': 'Fashion',
      'image': 'assets/images/products/boots.jpg',
      'daysAgo': 4,
    },
  ];

  static const List<Map<String, dynamic>> _baseDeals = [
    {
      'name': 'iPhone 15 Pro Max',
      'originalPrice': 210000,
      'dealPrice': 190000,
      'discount': 10,
      'endsIn': 'Today',
      'image': 'assets/images/products/iphone.jpg',
    },
    {
      'name': 'Samsung Galaxy S24 Ultra',
      'originalPrice': 120000,
      'dealPrice': 85550,
      'discount': 29,
      'endsIn': 'Today',
      'image': 'assets/images/products/samsung.jpg',
    },
  ];

  static const List<Map<String, dynamic>> _baseTopSellers = [
    {
      'name': 'Tech Store',
      'rating': 4.9,
      'products': 234,
      'image': 'assets/images/sellers/tech.png',
      'verified': true,
    },
    {
      'name': 'Fashion Hub',
      'rating': 4.8,
      'products': 567,
      'image': 'assets/images/sellers/fashion.png',
      'verified': true,
    },
    {
      'name': 'Home Decor',
      'rating': 4.7,
      'products': 189,
      'image': 'assets/images/sellers/home.png',
      'verified': false,
    },
    {
      'name': 'Sports World',
      'rating': 4.8,
      'products': 321,
      'image': 'assets/images/sellers/sports.png',
      'verified': true,
    },
  ];
}
