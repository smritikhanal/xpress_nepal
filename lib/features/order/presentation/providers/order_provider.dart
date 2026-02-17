import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../view_model/order_view_model.dart';
import '../../domain/repositories/order_repository.dart';

class OrderProvider {
  static OrderViewModel? _instance;

  static OrderViewModel get instance {
    if (_instance == null) {
      final apiClient = ApiClient();
      final OrderRemoteDataSource remote = OrderRemoteDataSourceImpl(apiClient.dio);
      final OrderRepository repo = OrderRepositoryImpl(remote);
      _instance = OrderViewModel(repo: repo);
    }
    return _instance!;
  }

  /// Set mock instance for testing
  @visibleForTesting
  static set instance(OrderViewModel? mock) {
    _instance = mock;
  }
}
