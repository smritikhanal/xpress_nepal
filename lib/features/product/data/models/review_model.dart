import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.id,
    required super.userId,
    super.userName,
    required super.productId,
    required super.rating,
    required super.comment,
    super.createdAt,
    super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // userId is populated by backend as { _id, name } — extract safely
    final userField = json['userId'];
    final String userId;
    final String? userName;
    if (userField is Map) {
      userId = userField['_id']?.toString() ?? '';
      userName = userField['name']?.toString();
    } else {
      userId = userField?.toString() ?? '';
      userName = null;
    }

    // productId is populated by backend as { _id, title, ... } — extract id safely
    final productField = json['productId'];
    final String productId;
    if (productField is Map) {
      productId = productField['_id']?.toString() ?? '';
    } else {
      productId = productField?.toString() ?? '';
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? '',
      userId: userId,
      userName: userName,
      productId: productId,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
