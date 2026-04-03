import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/cart_repository.dart';
import '../../domain/models/cart_data.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.read(dioProvider));
});

final cartProvider = FutureProvider<CartData>((ref) async {
  return ref.read(cartRepositoryProvider).getCart();
});

class CartController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final CartRepository repository;

  CartController({
    required this.ref,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.addToCart(productId: productId, quantity: quantity);
      ref.invalidate(cartProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateCartItem(itemId: itemId, quantity: quantity);
      ref.invalidate(cartProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> removeCartItem(int itemId) async {
    state = const AsyncValue.loading();
    try {
      await repository.removeCartItem(itemId);
      ref.invalidate(cartProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, AsyncValue<void>>((ref) {
  return CartController(
    ref: ref,
    repository: ref.read(cartRepositoryProvider),
  );
});