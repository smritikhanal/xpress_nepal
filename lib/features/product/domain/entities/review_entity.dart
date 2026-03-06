class ReviewEntity {
  final String id;
  final String userId;
  final String? userName;
  final String productId;
  final String? productTitle;
  final String? productImage;
  final int rating;
  final String comment;
  final String? createdAt;
  final String? updatedAt;

  ReviewEntity({
    required this.id,
    required this.userId,
    this.userName,
    required this.productId,
    this.productTitle,
    this.productImage,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });
}
