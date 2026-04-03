import '../../../../core/utils/json_parsers.dart';

class ProductReview {
  final int id;
  final int rating;
  final String? comment;
  final String? reviewDate;
  final int userId;
  final String userName;

  const ProductReview({
    required this.id,
    required this.rating,
    this.comment,
    this.reviewDate,
    required this.userId,
    required this.userName,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};

    return ProductReview(
      id: JsonParsers.toInt(json['id']),
      rating: JsonParsers.toInt(json['rating']),
      comment: JsonParsers.toNullableString(json['comment']),
      reviewDate: JsonParsers.toNullableString(json['reviewDate']),
      userId: JsonParsers.toInt(user['id']),
      userName: JsonParsers.toStringValue(user['name']),
    );
  }
}