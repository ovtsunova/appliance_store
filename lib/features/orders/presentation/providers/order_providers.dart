import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/models/delivery_type.dart';
import '../../domain/models/order_details.dart';
import '../../domain/models/order_summary.dart';
import '../../domain/models/payment_type.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.read(dioProvider));
});

final deliveryTypesProvider = FutureProvider<List<DeliveryType>>((ref) async {
  return ref.read(orderRepositoryProvider).getDeliveryTypes();
});

final paymentTypesProvider = FutureProvider<List<PaymentType>>((ref) async {
  return ref.read(orderRepositoryProvider).getPaymentTypes();
});

final ordersProvider = FutureProvider<List<OrderSummary>>((ref) async {
  return ref.read(orderRepositoryProvider).getOrders();
});

final orderDetailsProvider =
    FutureProvider.family<OrderDetails, int>((ref, orderId) async {
  return ref.read(orderRepositoryProvider).getOrderById(orderId);
});

class OrderController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final OrderRepository repository;

  OrderController({
    required this.ref,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  Future<void> createOrder({
    required int addressId,
    required int deliveryTypeId,
    required int paymentTypeId,
    String? orderComment,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.createOrder(
        addressId: addressId,
        deliveryTypeId: deliveryTypeId,
        paymentTypeId: paymentTypeId,
        orderComment: orderComment,
      );

      ref.invalidate(cartProvider);
      ref.invalidate(ordersProvider);
      ref.invalidate(profileProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> cancelOrder(int orderId) async {
    state = const AsyncValue.loading();
    try {
      await repository.cancelOrder(orderId);
      ref.invalidate(ordersProvider);
      ref.invalidate(orderDetailsProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final orderControllerProvider =
    StateNotifierProvider<OrderController, AsyncValue<void>>((ref) {
  return OrderController(
    ref: ref,
    repository: ref.read(orderRepositoryProvider),
  );
});