import 'package:dio/dio.dart';

import '../../domain/models/product_review.dart';

class ReviewRepository {
  final Dio dio;

  const ReviewRepository(this.dio);

  Future<List<ProductReview>> getReviewsByProduct(int productId) async {
    final response = await dio.get('/products/$productId/reviews');
    final data = response.data as List<dynamic>;

    return data
        .map((item) => ProductReview.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    await dio.post(
      '/products/$productId/reviews',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    await dio.patch(
      '/reviews/$reviewId',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<void> deleteReview(int reviewId) async {
    await dio.delete('/reviews/$reviewId');
  }
}