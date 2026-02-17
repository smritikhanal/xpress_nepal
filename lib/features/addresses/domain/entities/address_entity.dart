/// Address entity representing a shipping address
class AddressEntity {
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

  const AddressEntity({
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

  /// Get formatted full address
  String get fullAddress {
    final parts = [street, city, state, country];
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    return parts.join(', ');
  }

  /// Create a copy with updated values
  AddressEntity copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? country,
    String? state,
    String? city,
    String? street,
    String? postalCode,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      street: street ?? this.street,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
