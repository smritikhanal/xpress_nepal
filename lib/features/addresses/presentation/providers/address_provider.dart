import 'package:flutter/foundation.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/addresses/data/datasources/address_remote_datasource_impl.dart';
import 'package:xpress_nepal/features/addresses/data/repositories/address_repository_impl.dart';
import 'package:xpress_nepal/features/addresses/domain/datasources/address_remote_datasource.dart';
import 'package:xpress_nepal/features/addresses/domain/repositories/address_repository.dart';
import 'package:xpress_nepal/features/addresses/presentation/view_model/address_view_model.dart';

/// Provider for address-related dependencies
class AddressProvider {
  static AddressProvider? _instance;
  static AddressProvider get instance => _instance ??= AddressProvider._();

  /// Set mock instance for testing
  @visibleForTesting
  static set instance(AddressProvider? mock) {
    _instance = mock;
  }

  AddressProvider._();

  late AddressRemoteDataSource _remoteDataSource;
  late AddressRepository _addressRepository;
  late AddressViewModel _addressViewModel;

  bool _isInitialized = false;

  /// Initialize all address dependencies
  Future<void> initialize() async {
    if (_isInitialized) return;

    final apiService = ApiService();

    _remoteDataSource = AddressRemoteDataSourceImpl(apiService: apiService);
    _addressRepository = AddressRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );
    _addressViewModel = AddressViewModel(addressRepository: _addressRepository);

    _isInitialized = true;
  }

  /// Get address view model
  AddressViewModel get addressViewModel {
    if (!_isInitialized) {
      throw StateError(
        'AddressProvider not initialized. Call initialize() first.',
      );
    }
    return _addressViewModel;
  }

  /// Get address repository
  AddressRepository get addressRepository {
    if (!_isInitialized) {
      throw StateError(
        'AddressProvider not initialized. Call initialize() first.',
      );
    }
    return _addressRepository;
  }
}
