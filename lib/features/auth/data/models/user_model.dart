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

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
  });

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email);
  }

  /// Create from domain entity (requires password hash)
  factory UserModel.fromEntity(UserEntity entity, String passwordHash) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      passwordHash: passwordHash,
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }
}
