
import 'package:xpress_nepal/features/product/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.id,
    required super.userId,
    required super.productId,
    required super.rating,
    required super.comment,
    super.createdAt,
    super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      userId: json['userId'] is String 
          ? json['userId'] 
          : (json['userId'] != null ? json['userId']['name'] ?? json['userId']['_id'] ?? '' : ''), 
      // Handling population if it happens, assuming backend might populate or not. 
      // The backend controller shows .populate('userId', 'name'), so userId field will be an object.
      // But let's check the backend controller again. 
      // Backend: .populate('userId', 'name')
      // So userId will be { _id: "...", name: "..." }
      // The original frontend code was just using json['userId'] ?? ''.
      // Let's make it robust.
      productId: json['productId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
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
