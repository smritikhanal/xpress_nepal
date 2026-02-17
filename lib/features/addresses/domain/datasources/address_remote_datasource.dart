import 'package:xpress_nepal/features/addresses/data/models/address_model.dart';

/// Result from address API operations
class AddressApiResult {
  final bool success;
  final String? message;
  final AddressModel? address;
  final List<AddressModel>? addresses;

  AddressApiResult({
    required this.success,
    this.message,
    this.address,
    this.addresses,
  });
}

/// Abstract data source for remote address operations
abstract class AddressRemoteDataSource {
  /// Get all addresses for current user
  Future<AddressApiResult> getAddresses();

  /// Add a new address
  Future<AddressApiResult> addAddress({
    required String fullName,
    required String phone,
    required String country,
    required String state,
    required String city,
    required String street,
    String? postalCode,
    bool isDefault = false,
  });

  /// Update an existing address
  Future<AddressApiResult> updateAddress({
    required String addressId,
    String? fullName,
    String? phone,
    String? country,
    String? state,
    String? city,
    String? street,
    String? postalCode,
    bool? isDefault,
  });

  /// Delete an address
  Future<AddressApiResult> deleteAddress(String addressId);
}
