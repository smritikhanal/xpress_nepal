/// User entity representing the core business object
/// Pure Dart – no external dependencies
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final String? shopName;
  final String? businessDescription;
  final String? createdAt;
  final String? updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'customer',
    this.isActive = true,
    this.shopName,
    this.businessDescription,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.role == role &&
        other.isActive == isActive &&
        other.shopName == shopName &&
        other.businessDescription == businessDescription &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        role.hashCode ^
        isActive.hashCode ^
        shopName.hashCode ^
        businessDescription.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'phone: $phone, '
        'role: $role, '
        'isActive: $isActive'
        ')';
  }
}
