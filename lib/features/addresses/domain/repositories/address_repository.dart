import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';

/// Result from address repository operations
class AddressResult {
  final bool success;
  final String? message;
  final AddressEntity? address;
  final List<AddressEntity>? addresses;

  const AddressResult({
    required this.success,
    this.message,
    this.address,
    this.addresses,
  });

  factory AddressResult.success({
    String? message,
    AddressEntity? address,
    List<AddressEntity>? addresses,
  }) {
    return AddressResult(
      success: true,
      message: message,
      address: address,
      addresses: addresses,
    );
  }

  factory AddressResult.failure(String message) {
    return AddressResult(success: false, message: message);
  }
}

/// Abstract repository for address operations
abstract class AddressRepository {
  /// Get all addresses for current user
  Future<AddressResult> getAddresses();

  /// Add a new address
  Future<AddressResult> addAddress({
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
  Future<AddressResult> updateAddress({
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
  Future<AddressResult> deleteAddress(String addressId);

  /// Set an address as default
  Future<AddressResult> setDefaultAddress(String addressId);
}
