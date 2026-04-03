import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/utils/json_parsers.dart';
import '../../../catalog/domain/models/brand.dart';
import '../../../catalog/domain/models/category.dart';
import '../../../catalog/domain/models/product.dart';
import '../../domain/models/admin_backup_item.dart';
import '../../domain/models/admin_models.dart';
import '../../domain/models/admin_product_characteristic_item.dart';

class AdminRepository {
  final Dio dio;

  const AdminRepository(this.dio);

  Future<List<AdminProductItem>> getProducts() async {
    final response = await dio.get('/admin/products');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => AdminProductItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductDetails(int productId) async {
    final response = await dio.get('/products/$productId');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<int> createProduct({
    required String productName,
    required String description,
    required String model,
    required int price,
    required int stockQuantity,
    required String imageUrl,
    required String warrantyPeriod,
    required int brandId,
    required int categoryId,
  }) async {
    final response = await dio.post(
      '/admin/products',
      data: {
        'productName': productName,
        'description': description,
        'model': model,
        'price': price,
        'stockQuantity': stockQuantity,
        'imageUrl': imageUrl,
        'warrantyPeriod': warrantyPeriod,
        'brandId': brandId,
        'categoryId': categoryId,
      },
    );

    final data = response.data;
    if (data is! Map) {
      throw Exception('Некорректный ответ сервера при создании товара');
    }

    final rawProductId = data['productId'];
    if (rawProductId == null) {
      throw Exception('Сервер не вернул ID созданного товара');
    }

    return JsonParsers.toInt(rawProductId);
  }

  Future<void> updateProduct({
    required int productId,
    required String productName,
    required String description,
    required String model,
    required int price,
    required int stockQuantity,
    required String imageUrl,
    required String warrantyPeriod,
    required int brandId,
    required int categoryId,
  }) async {
    await dio.patch(
      '/admin/products/$productId',
      data: {
        'productName': productName,
        'description': description,
        'model': model,
        'price': price,
        'stockQuantity': stockQuantity,
        'imageUrl': imageUrl,
        'warrantyPeriod': warrantyPeriod,
        'brandId': brandId,
        'categoryId': categoryId,
      },
    );
  }

  Future<void> deleteProduct(int productId) async {
    await dio.delete('/admin/products/$productId');
  }

  Future<List<AdminProductCharacteristicItem>> getProductCharacteristics(
    int productId,
  ) async {
    final response = await dio.get('/admin/products/$productId/characteristics');
    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => AdminProductCharacteristicItem.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> createProductCharacteristic({
    required int productId,
    required String name,
    required String value,
  }) async {
    await dio.post(
      '/admin/products/$productId/characteristics',
      data: {
        'name': name,
        'value': value,
      },
    );
  }

  Future<void> updateProductCharacteristic({
    required int characteristicId,
    required String name,
    required String value,
  }) async {
    await dio.patch(
      '/admin/characteristics/$characteristicId',
      data: {
        'name': name,
        'value': value,
      },
    );
  }

  Future<void> deleteProductCharacteristic(int characteristicId) async {
    await dio.delete('/admin/characteristics/$characteristicId');
  }

  Future<List<Category>> getCategories() async {
    final response = await dio.get('/categories');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCategory({
    required String name,
    required String description,
    int? parentCategoryId,
  }) async {
    await dio.post(
      '/admin/categories',
      data: {
        'name': name,
        'description': description,
        'parentCategoryId': parentCategoryId,
      },
    );
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    int? parentCategoryId,
  }) async {
    await dio.patch(
      '/admin/categories/$categoryId',
      data: {
        'name': name,
        'description': description,
        'parentCategoryId': parentCategoryId,
      },
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    await dio.delete('/admin/categories/$categoryId');
  }

  Future<List<Brand>> getBrands() async {
    final response = await dio.get('/brands');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => Brand.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBrand({
    required String name,
    required String countryOfOrigin,
    required String contactInfo,
  }) async {
    await dio.post(
      '/admin/brands',
      data: {
        'name': name,
        'countryOfOrigin': countryOfOrigin,
        'contactInfo': contactInfo,
      },
    );
  }

  Future<void> updateBrand({
    required int brandId,
    required String name,
    required String countryOfOrigin,
    required String contactInfo,
  }) async {
    await dio.patch(
      '/admin/brands/$brandId',
      data: {
        'name': name,
        'countryOfOrigin': countryOfOrigin,
        'contactInfo': contactInfo,
      },
    );
  }

  Future<void> deleteBrand(int brandId) async {
    await dio.delete('/admin/brands/$brandId');
  }

  Future<List<AdminOrderItem>> getOrders() async {
    final response = await dio.get('/admin/orders');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => AdminOrderItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AdminOrderStatusOption>> getOrderStatuses() async {
    final response = await dio.get('/admin/order-statuses');
    final data = response.data as List<dynamic>;
    return data
        .map(
          (item) => AdminOrderStatusOption.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> changeOrderStatus({
    required int orderId,
    required int statusId,
  }) async {
    await dio.patch(
      '/admin/orders/$orderId/status',
      data: {
        'statusId': statusId,
      },
    );
  }

  Future<List<AdminUserItem>> getUsers() async {
    final response = await dio.get('/admin/users');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => AdminUserItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AdminRoleOption>> getRoles() async {
    final response = await dio.get('/admin/roles');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => AdminRoleOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> changeUserRole({
    required int userId,
    required int roleId,
  }) async {
    await dio.patch(
      '/admin/users/$userId/role',
      data: {
        'roleId': roleId,
      },
    );
  }

  Future<void> blockUser(int userId) async {
    await dio.patch('/admin/users/$userId/block');
  }

  Future<void> unblockUser(int userId) async {
    await dio.patch('/admin/users/$userId/unblock');
  }

  Future<List<AdminReviewItem>> getReviews() async {
    final response = await dio.get('/admin/reviews');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => AdminReviewItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteReview(int reviewId) async {
    await dio.delete('/admin/reviews/$reviewId');
  }

  Future<AdminIncomeStats> getIncomeStats() async {
    final response = await dio.get('/admin/stats/income?days=30');
    return AdminIncomeStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AdminTopProductItem>> getTopProductsStats() async {
    final response = await dio.get('/admin/stats/top-products?days=30&limit=5');
    final data = response.data as Map<String, dynamic>;
    final items = data['period']['items'] as List<dynamic>? ?? [];
    return items
        .map(
          (item) => AdminTopProductItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<AdminTopUserItem>> getTopUsersStats() async {
    final response = await dio.get('/admin/stats/top-users?days=30&limit=5');
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map(
          (item) => AdminTopUserItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<AuditLogItem>> getAuditLog() async {
    final response = await dio.get('/admin/audit?limit=100');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => AuditLogItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Uint8List> exportOrdersCsv() async {
    final response = await dio.get<List<int>>(
      '/admin/export/orders',
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data ?? []);
  }

  Future<Map<String, dynamic>> createBackup() async {
    final response = await dio.post('/admin/backup');
    return response.data as Map<String, dynamic>;
  }

  Future<List<AdminBackupItem>> getBackups() async {
    final response = await dio.get('/admin/backups');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => AdminBackupItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> restoreBackup({String? filePath}) async {
    final response = await dio.post(
      '/admin/restore',
      data: {
        'filePath': filePath,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}