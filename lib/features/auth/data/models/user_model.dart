import 'package:hive/hive.dart';
import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// UserModel extends UserEntity and adds Hive serialization
/// This model is used in the data layer for persistence
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String role;

  @HiveField(6)
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.phone,
    this.role = 'customer',
    this.token,
  });

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
    );
  }

  /// Create from domain entity (requires password hash)
  factory UserModel.fromEntity(UserEntity entity, String passwordHash) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      passwordHash: passwordHash,
      phone: entity.phone,
      role: entity.role,
    );
  }

  /// Create from API JSON response
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      passwordHash: '', // Password is not returned from API
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      token: token,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phone: $phone, role: $role)';
  }
}
