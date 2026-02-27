import 'package:flutter/foundation.dart';
import 'package:xpress_nepal/features/home/data/repositories/home_content_repository.dart';

class HomeContentProvider extends ChangeNotifier {
  HomeContentProvider({required HomeContentRepository repository})
    : _repository = repository;

  final HomeContentRepository _repository;

  bool _isLoading = false;
  bool _isOfflineMode = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _banners = const [];
  List<Map<String, dynamic>> _categories = const [];
  List<Map<String, dynamic>> _flashSaleProducts = const [];
  List<Map<String, dynamic>> _trendingProducts = const [];
  List<Map<String, dynamic>> _newArrivals = const [];
  List<Map<String, dynamic>> _deals = const [];
  List<Map<String, dynamic>> _topSellers = const [];

  bool _initialized = false;

  bool get isLoading => _isLoading;
  bool get isOfflineMode => _isOfflineMode;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> get banners => _banners;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get flashSaleProducts => _flashSaleProducts;
  List<Map<String, dynamic>> get trendingProducts => _trendingProducts;
  List<Map<String, dynamic>> get newArrivals => _newArrivals;
  List<Map<String, dynamic>> get deals => _deals;
  List<Map<String, dynamic>> get topSellers => _topSellers;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await refreshAll();
  }

  Future<void> refreshAll() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = await _repository.fetchHomeContent();
      _banners = payload.banners;
      _categories = payload.categories;
      _flashSaleProducts = payload.flashSaleProducts;
      _trendingProducts = payload.trendingProducts;
      _newArrivals = payload.newArrivals;
      _deals = payload.deals;
      _topSellers = payload.topSellers;
      _isOfflineMode = payload.fromOffline;
    } catch (e) {
      _errorMessage = 'Failed to refresh home content: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
