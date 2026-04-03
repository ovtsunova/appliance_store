import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/models/product_review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.read(dioProvider));
});

final productReviewsProvider =
    FutureProvider.family<List<ProductReview>, int>((ref, productId) async {
  return ref.read(reviewRepositoryProvider).getReviewsByProduct(productId);
});

class ReviewController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final ReviewRepository repository;

  ReviewController({
    required this.ref,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  void _refreshProductData(int productId) {
    ref.invalidate(productReviewsProvider(productId));
    ref.invalidate(productByIdProvider(productId));
    ref.invalidate(catalogProductsProvider);
  }

  Future<void> createReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      _refreshProductData(productId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateReview({
    required int productId,
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      _refreshProductData(productId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteReview({
    required int productId,
    required int reviewId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteReview(reviewId);
      _refreshProductData(productId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final reviewControllerProvider =
    StateNotifierProvider<ReviewController, AsyncValue<void>>((ref) {
  return ReviewController(
    ref: ref,
    repository: ref.read(reviewRepositoryProvider),
  );
});