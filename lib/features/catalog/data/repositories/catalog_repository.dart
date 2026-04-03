import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/models/product.dart';

class CatalogRepository {
  final Dio dio;

  CatalogRepository({required this.dio});

  Future<List<Product>> getProducts() async {
    final response = await dio.get(ApiConstants.products);
    final data = response.data as List<dynamic>;

    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductById(int id) async {
    final response = await dio.get(ApiConstants.productById(id));
    return Product.fromJson(response.data as Map<String, dynamic>);
  }
}