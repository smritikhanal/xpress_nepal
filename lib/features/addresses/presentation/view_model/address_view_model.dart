import 'package:flutter/foundation.dart';
import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';
import 'package:xpress_nepal/features/addresses/domain/repositories/address_repository.dart';
import 'package:xpress_nepal/features/addresses/presentation/state/address_state.dart';

/// ViewModel for address operations
class AddressViewModel extends ChangeNotifier {
  final AddressRepository _addressRepository;

  AddressState _state = AddressState.initial();
  AddressState get state => _state;

  AddressViewModel({required AddressRepository addressRepository})
    : _addressRepository = addressRepository;

  /// Get error message
  String? get errorMessage => _state.errorMessage;

  /// Get all addresses
  List<AddressEntity> get addresses => _state.addresses;

  /// Get default address
  AddressEntity? get defaultAddress => _state.defaultAddress;

  /// Check if loading
  bool get isLoading => _state.isLoading;

  /// Fetch all addresses
  Future<void> fetchAddresses() async {
    _state = AddressState.loading();
    notifyListeners();

    final result = await _addressRepository.getAddresses();

    if (result.success && result.addresses != null) {
      _state = AddressState.loaded(result.addresses!);
    } else {
      _state = AddressState.error(
        result.message ?? 'Failed to fetch addresses',
      );
    }
    notifyListeners();
  }

  /// Add a new address
  Future<bool> addAddress({
    required String fullName,
    required String phone,
    required String country,
    required String state,
    required String city,
    required String street,
    String? postalCode,
    bool isDefault = false,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _addressRepository.addAddress(
      fullName: fullName,
      phone: phone,
      country: country,
      state: state,
      city: city,
      street: street,
      postalCode: postalCode,
      isDefault: isDefault,
    );

    if (result.success) {
      await fetchAddresses(); // Refresh list
      return true;
    } else {
      _state = _state.copyWith(isLoading: false, errorMessage: result.message);
      notifyListeners();
      return false;
    }
  }

  /// Update an existing address
  Future<bool> updateAddress({
    required String addressId,
    String? fullName,
    String? phone,
    String? country,
    String? state,
    String? city,
    String? street,
    String? postalCode,
    bool? isDefault,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _addressRepository.updateAddress(
      addressId: addressId,
      fullName: fullName,
      phone: phone,
      country: country,
      state: state,
      city: city,
      street: street,
      postalCode: postalCode,
      isDefault: isDefault,
    );

    if (result.success) {
      await fetchAddresses(); // Refresh list
      return true;
    } else {
      _state = _state.copyWith(isLoading: false, errorMessage: result.message);
      notifyListeners();
      return false;
    }
  }

  /// Delete an address
  Future<bool> deleteAddress(String addressId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _addressRepository.deleteAddress(addressId);

    if (result.success) {
      await fetchAddresses(); // Refresh list
      return true;
    } else {
      _state = _state.copyWith(isLoading: false, errorMessage: result.message);
      notifyListeners();
      return false;
    }
  }

  /// Set an address as default
  Future<bool> setDefaultAddress(String addressId) async {
    return updateAddress(addressId: addressId, isDefault: true);
  }

  /// Select an address
  void selectAddress(AddressEntity address) {
    _state = _state.copyWith(selectedAddress: address);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}
