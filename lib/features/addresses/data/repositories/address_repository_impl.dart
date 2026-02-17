import 'package:xpress_nepal/features/addresses/domain/datasources/address_remote_datasource.dart';
import 'package:xpress_nepal/features/addresses/domain/repositories/address_repository.dart';

/// Implementation of AddressRepository
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepositoryImpl({required AddressRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<AddressResult> getAddresses() async {
    try {
      final result = await _remoteDataSource.getAddresses();

      if (result.success && result.addresses != null) {
        return AddressResult.success(
          addresses: result.addresses!.map((m) => m.toEntity()).toList(),
        );
      }

      return AddressResult.failure(
        result.message ?? 'Failed to fetch addresses',
      );
    } catch (e) {
      return AddressResult.failure('Error fetching addresses: ${e.toString()}');
    }
  }

  @override
  Future<AddressResult> addAddress({
    required String fullName,
    required String phone,
    required String country,
    required String state,
    required String city,
    required String street,
    String? postalCode,
    bool isDefault = false,
  }) async {
    try {
      final result = await _remoteDataSource.addAddress(
        fullName: fullName,
        phone: phone,
        country: country,
        state: state,
        city: city,
        street: street,
        postalCode: postalCode,
        isDefault: isDefault,
      );

      if (result.success && result.address != null) {
        return AddressResult.success(
          message: result.message,
          address: result.address!.toEntity(),
        );
      }

      return AddressResult.failure(result.message ?? 'Failed to add address');
    } catch (e) {
      return AddressResult.failure('Error adding address: ${e.toString()}');
    }
  }

  @override
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
  }) async {
    try {
      final result = await _remoteDataSource.updateAddress(
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

      if (result.success && result.address != null) {
        return AddressResult.success(
          message: result.message,
          address: result.address!.toEntity(),
        );
      }

      return AddressResult.failure(
        result.message ?? 'Failed to update address',
      );
    } catch (e) {
      return AddressResult.failure('Error updating address: ${e.toString()}');
    }
  }

  @override
  Future<AddressResult> deleteAddress(String addressId) async {
    try {
      final result = await _remoteDataSource.deleteAddress(addressId);

      if (result.success) {
        return AddressResult.success(message: result.message);
      }

      return AddressResult.failure(
        result.message ?? 'Failed to delete address',
      );
    } catch (e) {
      return AddressResult.failure('Error deleting address: ${e.toString()}');
    }
  }

  @override
  Future<AddressResult> setDefaultAddress(String addressId) async {
    return updateAddress(addressId: addressId, isDefault: true);
  }
}
