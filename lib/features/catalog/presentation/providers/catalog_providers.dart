import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../domain/models/product.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(
    dio: ref.read(dioProvider),
  );
});

final catalogProductsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.read(catalogRepositoryProvider).getProducts();
});

final productByIdProvider =
    FutureProvider.family<Product, int>((ref, productId) async {
  return ref.read(catalogRepositoryProvider).getProductById(productId);
});

class CompareController extends StateNotifier<Set<int>> {
  CompareController() : super({});

  void toggle(int productId) {
    final updated = Set<int>.from(state);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = updated;
  }

  void clear() {
    state = {};
  }

  bool contains(int productId) {
    return state.contains(productId);
  }
}

final compareProductsProvider =
    StateNotifierProvider<CompareController, Set<int>>((ref) {
  return CompareController();
});