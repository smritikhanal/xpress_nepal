import '../../domain/entities/user_entity.dart';

class UserApiModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  /// Used only for auth requests (login/register)
  final String? password;

  UserApiModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'customer',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.password,
  });

  // ================= JSON → MODEL =================
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  // ================= MODEL → JSON =================
  /// Used for API requests (register / update profile)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
    };

    if (phone != null) json['phone'] = phone!;
    if (password != null) json['password'] = password!;

    return json;
  }

  // ================= MODEL → ENTITY =================
  UserEntity toEntity() {
    return UserEntity(
      id: id ?? '',
      name: name,
      email: email,
      phone: phone,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ================= ENTITY → MODEL =================
  factory UserApiModel.fromEntity(UserEntity entity, {String? password}) {
    return UserApiModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      password: password,
    );
  }
}
