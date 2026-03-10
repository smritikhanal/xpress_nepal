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

    return HomeContentPayload(
      banners: List<Map<String, dynamic>>.from(_baseBanners),
      categories: List<Map<String, dynamic>>.from(_baseCategories),
      flashSaleProducts: [], // Now using ProductProvider
      trendingProducts: [], // Now using ProductProvider
      newArrivals: [], // Now using ProductProvider
      deals: [], // Now using ProductProvider
      topSellers: [], // Hide until sellers endpoint available
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
        flashSaleProducts: [], // Now using ProductProvider
        trendingProducts: [], // Now using ProductProvider
        newArrivals: [], // Now using ProductProvider
        deals: [], // Now using ProductProvider
        topSellers: [], // Hide until sellers endpoint available
        fromOffline: true,
      );
    }

    return HomeContentPayload(
      banners: List<Map<String, dynamic>>.from(_baseBanners),
      categories: List<Map<String, dynamic>>.from(_baseCategories),
      flashSaleProducts: [], // Now using ProductProvider
      trendingProducts: [], // Now using ProductProvider
      newArrivals: [], // Now using ProductProvider
      deals: [], // Now using ProductProvider
      topSellers: [], // Hide until sellers endpoint available
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
    {'name': 'Electronics', 'icon': 'devices_rounded', 'items': 856},
    {'name': 'Fashion', 'icon': 'checkroom_rounded', 'items': 1234},
    {
      'name': 'Groceries & Essentials',
      'icon': 'shopping_basket_rounded',
      'items': 1540,
    },
    {'name': 'Toys & Kids', 'icon': 'toys_rounded', 'items': 654},
    {'name': 'Jewelry & Watches', 'icon': 'watch_rounded', 'items': 432},
    {'name': 'Beauty & Health', 'icon': 'face_rounded', 'items': 567},
    {'name': 'Automotive', 'icon': 'directions_car_rounded', 'items': 389},
    {
      'name': 'Sports & Fitness',
      'icon': 'sports_basketball_rounded',
      'items': 512,
    },
    {'name': 'Books & Media', 'icon': 'menu_book_rounded', 'items': 890},
  ];
}
