import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/addresses/data/models/address_model.dart';
import 'package:xpress_nepal/features/addresses/domain/datasources/address_remote_datasource.dart';

/// Implementation of AddressRemoteDataSource
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiService _apiService;

  AddressRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<AddressApiResult> getAddresses() async {
    try {
      final response = await _apiService.get(
        ApiConstants.addresses,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        // The response.data contains the full JSON body: { success, message, data }
        // The actual addresses are in response.data['data']
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> addressList = responseData['data'] is List
            ? responseData['data'] as List<dynamic>
            : [];

        final addresses = addressList
            .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return AddressApiResult(success: true, addresses: addresses);
      }

      return AddressApiResult(
        success: false,
        message: response.message ?? 'Failed to fetch addresses',
      );
    } catch (e) {
      return AddressApiResult(
        success: false,
        message: 'Error fetching addresses: ${e.toString()}',
      );
    }
  }

  @override
  Future<AddressApiResult> addAddress({
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
      final response = await _apiService.post(
        ApiConstants.addresses,
        body: {
          'fullName': fullName.trim(),
          'phone': phone.trim(),
          'country': country.trim(),
          'state': state.trim(),
          'city': city.trim(),
          'street': street.trim(),
          if (postalCode != null) 'postalCode': postalCode.trim(),
          'isDefault': isDefault,
        },
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final address = AddressModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        return AddressApiResult(
          success: true,
          message: response.message ?? 'Address added successfully',
          address: address,
        );
      }

      return AddressApiResult(
        success: false,
        message: response.message ?? 'Failed to add address',
      );
    } catch (e) {
      return AddressApiResult(
        success: false,
        message: 'Error adding address: ${e.toString()}',
      );
    }
  }

  @override
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
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName.trim();
      if (phone != null) body['phone'] = phone.trim();
      if (country != null) body['country'] = country.trim();
      if (state != null) body['state'] = state.trim();
      if (city != null) body['city'] = city.trim();
      if (street != null) body['street'] = street.trim();
      if (postalCode != null) body['postalCode'] = postalCode.trim();
      if (isDefault != null) body['isDefault'] = isDefault;

      final response = await _apiService.put(
        '${ApiConstants.addresses}/$addressId',
        body: body,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final address = AddressModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        return AddressApiResult(
          success: true,
          message: response.message ?? 'Address updated successfully',
          address: address,
        );
      }

      return AddressApiResult(
        success: false,
        message: response.message ?? 'Failed to update address',
      );
    } catch (e) {
      return AddressApiResult(
        success: false,
        message: 'Error updating address: ${e.toString()}',
      );
    }
  }

  @override
  Future<AddressApiResult> deleteAddress(String addressId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.addresses}/$addressId',
        requiresAuth: true,
      );

      if (response.success) {
        return AddressApiResult(
          success: true,
          message: response.message ?? 'Address deleted successfully',
        );
      }

      return AddressApiResult(
        success: false,
        message: response.message ?? 'Failed to delete address',
      );
    } catch (e) {
      return AddressApiResult(
        success: false,
        message: 'Error deleting address: ${e.toString()}',
      );
    }
  }
}
