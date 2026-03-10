import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';

/// Address model for API communication
class AddressModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String street;
  final String? postalCode;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.street,
    this.postalCode,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      country: json['country'] as String? ?? 'Nepal',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      street: json['street'] as String? ?? '',
      postalCode: json['postalCode'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'country': country,
      'state': state,
      'city': city,
      'street': street,
      if (postalCode != null) 'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  /// Convert to entity
  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      userId: userId,
      fullName: fullName,
      phone: phone,
      country: country,
      state: state,
      city: city,
      street: street,
      postalCode: postalCode,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      userId: entity.userId,
      fullName: entity.fullName,
      phone: entity.phone,
      country: entity.country,
      state: entity.state,
      city: entity.city,
      street: entity.street,
      postalCode: entity.postalCode,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
