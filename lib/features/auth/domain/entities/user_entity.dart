/// User entity representing the core business object
/// This is a pure Dart class with no dependencies on external packages
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'customer',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.role == role;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      role.hashCode;

  @override
  String toString() =>
      'UserEntity(id: $id, name: $name, email: $email, phone: $phone, role: $role)';
}
