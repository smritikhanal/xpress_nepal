class ReviewEntity {
  final String id;
  final String userId;
  final String? userName;
  final String productId;
  final int rating;
  final String comment;
  final String? createdAt;
  final String? updatedAt;

  ReviewEntity({
    required this.id,
    required this.userId,
    this.userName,
    required this.productId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });
}
