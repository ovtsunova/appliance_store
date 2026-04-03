import 'package:dio/dio.dart';

import '../../domain/models/cart_data.dart';

class CartRepository {
  final Dio dio;

  const CartRepository(this.dio);

  Future<CartData> getCart() async {
    final response = await dio.get('/cart');
    return CartData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    await dio.post(
      '/cart',
      data: {
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  Future<void> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    await dio.patch(
      '/cart/$itemId',
      data: {
        'quantity': quantity,
      },
    );
  }

  Future<void> removeCartItem(int itemId) async {
    await dio.delete('/cart/$itemId');
  }
}