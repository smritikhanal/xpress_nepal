import 'package:hive/hive.dart';
import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// UserModel for local persistence (Hive)
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final String? token;

  @HiveField(7)
  final String? createdAt;

  @HiveField(8)
  final String? updatedAt;

  @HiveField(9)
  final String? shopName;

  @HiveField(10)
  final String? businessDescription;

  @HiveField(11)
  final String? image;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'customer',
    this.isActive = true,
    this.token,
    this.createdAt,
    this.updatedAt,
    this.shopName,
    this.businessDescription,
    this.image,
  });

  // ================= MODEL → ENTITY =================
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      isActive: isActive,
      shopName: shopName,
      businessDescription: businessDescription,
      image: image,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ================= ENTITY → MODEL =================
  factory UserModel.fromEntity(UserEntity entity, {String? token}) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      isActive: entity.isActive,
      shopName: entity.shopName,
      businessDescription: entity.businessDescription,
      image: entity.image,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      token: token,
    );
  }

  // ================= JSON → MODEL =================
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      // Backend auth response uses 'id', MongoDB queries use '_id'
      id: (json['id'] ?? json['_id']) as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      isActive: json['isActive'] as bool? ?? true,
      shopName: json['shopName'] as String?,
      businessDescription: json['businessDescription'] as String?,
      image: json['image'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      token: token,
    );
  }

  // ================= MODEL → JSON =================
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'shopName': shopName,
      'businessDescription': businessDescription,
      if (image != null) 'image': image,
    };
  }

  // ================= COPY WITH =================
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    String? token,
    String? createdAt,
    String? updatedAt,
    String? shopName,
    String? businessDescription,
    String? image,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shopName: shopName ?? this.shopName,
      businessDescription: businessDescription ?? this.businessDescription,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, isActive: $isActive)';
  }
}
