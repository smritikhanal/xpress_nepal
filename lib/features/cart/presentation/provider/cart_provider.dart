import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasource/cart_remote_datasource.dart';
import '../../data/datasource/cart_remote_datasource_impl.dart';
import '../../data/repositories/cart_repo_impl.dart';
import '../../domain/repositories/cart_repo.dart';
import '../view_model/cart_view_model.dart';

/// Singleton instance for cart view model
class CartProvider {
  static CartViewModel? _instance;

  static CartViewModel get instance {
    if (_instance == null) {
      // Create dependencies
      final apiClient = ApiClient();
      final CartRemoteDataSource remoteDataSource = CartRemoteDataSourceImpl(apiClient.dio);
      final CartRepo repo = CartRepoImpl(remoteDataSource);
      
      // Create view model
      _instance = CartViewModel(repo: repo);
    }
    return _instance!;
  }

  @visibleForTesting
  static set instance(CartViewModel? value) {
    _instance = value;
  }

  // Reset instance (useful for testing or logout)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}
