import 'package:dio/dio.dart';

import '../../domain/models/delivery_type.dart';
import '../../domain/models/order_details.dart';
import '../../domain/models/order_summary.dart';
import '../../domain/models/payment_type.dart';

class OrderRepository {
  final Dio dio;

  const OrderRepository(this.dio);

  Future<List<DeliveryType>> getDeliveryTypes() async {
    final response = await dio.get('/delivery-types');
    final data = response.data as List<dynamic>;

    return data
        .map((item) => DeliveryType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PaymentType>> getPaymentTypes() async {
    final response = await dio.get('/payment-types');
    final data = response.data as List<dynamic>;

    return data
        .map((item) => PaymentType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderSummary>> getOrders() async {
    final response = await dio.get('/orders');
    final data = response.data as List<dynamic>;

    return data
        .map((item) => OrderSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderDetails> getOrderById(int orderId) async {
    final response = await dio.get('/orders/$orderId');
    return OrderDetails.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createOrder({
    required int addressId,
    required int deliveryTypeId,
    required int paymentTypeId,
    String? orderComment,
  }) async {
    await dio.post(
      '/orders',
      data: {
        'addressId': addressId,
        'deliveryTypeId': deliveryTypeId,
        'paymentTypeId': paymentTypeId,
        'orderComment': orderComment ?? '',
      },
    );
  }

  Future<void> cancelOrder(int orderId) async {
    await dio.patch('/orders/$orderId/cancel');
  }
}