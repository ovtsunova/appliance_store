import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../domain/models/favorite_item.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.read(dioProvider));
});

final favoritesProvider = FutureProvider<List<FavoriteItem>>((ref) async {
  return ref.read(favoritesRepositoryProvider).getFavorites();
});

class FavoritesController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final FavoritesRepository repository;

  FavoritesController({
    required this.ref,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  Future<void> addFavorite(int productId) async {
    state = const AsyncValue.loading();
    try {
      await repository.addFavorite(productId);
      ref.invalidate(favoritesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> removeFavorite(int productId) async {
    state = const AsyncValue.loading();
    try {
      await repository.removeFavorite(productId);
      ref.invalidate(favoritesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, AsyncValue<void>>((ref) {
  return FavoritesController(
    ref: ref,
    repository: ref.read(favoritesRepositoryProvider),
  );
});