import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/models/brand.dart';
import '../../../catalog/domain/models/category.dart';
import '../../data/repositories/admin_repository.dart';
import '../../domain/models/admin_backup_item.dart';
import '../../domain/models/admin_models.dart';
import '../../domain/models/admin_product_characteristic_item.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(dioProvider));
});

final adminProductsProvider =
    FutureProvider<List<AdminProductItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getProducts();
});

final adminCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.read(adminRepositoryProvider).getCategories();
});

final adminBrandsProvider = FutureProvider<List<Brand>>((ref) async {
  return ref.read(adminRepositoryProvider).getBrands();
});

final adminProductCharacteristicsProvider =
    FutureProvider.family<List<AdminProductCharacteristicItem>, int>(
  (ref, productId) async {
    return ref.read(adminRepositoryProvider).getProductCharacteristics(productId);
  },
);

final adminOrdersProvider = FutureProvider<List<AdminOrderItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getOrders();
});

final adminOrderStatusesProvider =
    FutureProvider<List<AdminOrderStatusOption>>((ref) async {
  return ref.read(adminRepositoryProvider).getOrderStatuses();
});

final adminUsersProvider = FutureProvider<List<AdminUserItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getUsers();
});

final adminRolesProvider = FutureProvider<List<AdminRoleOption>>((ref) async {
  return ref.read(adminRepositoryProvider).getRoles();
});

final adminReviewsProvider = FutureProvider<List<AdminReviewItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getReviews();
});

final adminIncomeStatsProvider =
    FutureProvider<AdminIncomeStats>((ref) async {
  return ref.read(adminRepositoryProvider).getIncomeStats();
});

final adminTopProductsStatsProvider =
    FutureProvider<List<AdminTopProductItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getTopProductsStats();
});

final adminTopUsersStatsProvider =
    FutureProvider<List<AdminTopUserItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getTopUsersStats();
});

final adminAuditLogProvider = FutureProvider<List<AuditLogItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getAuditLog();
});

final adminBackupsProvider = FutureProvider<List<AdminBackupItem>>((ref) async {
  return ref.read(adminRepositoryProvider).getBackups();
});

class AdminController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final AdminRepository repository;

  AdminController({
    required this.ref,
    required this.repository,
  }) : super(const AsyncValue.data(null));

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
    state = const AsyncValue.loading();
    try {
      final productId = await repository.createProduct(
        productName: productName,
        description: description,
        model: model,
        price: price,
        stockQuantity: stockQuantity,
        imageUrl: imageUrl,
        warrantyPeriod: warrantyPeriod,
        brandId: brandId,
        categoryId: categoryId,
      );
      ref.invalidate(adminProductsProvider);
      state = const AsyncValue.data(null);
      return productId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
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
    state = const AsyncValue.loading();
    try {
      await repository.updateProduct(
        productId: productId,
        productName: productName,
        description: description,
        model: model,
        price: price,
        stockQuantity: stockQuantity,
        imageUrl: imageUrl,
        warrantyPeriod: warrantyPeriod,
        brandId: brandId,
        categoryId: categoryId,
      );
      ref.invalidate(adminProductsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteProduct(productId);
      ref.invalidate(adminProductsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createProductCharacteristic({
    required int productId,
    required String name,
    required String value,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.createProductCharacteristic(
        productId: productId,
        name: name,
        value: value,
      );
      ref.invalidate(adminProductCharacteristicsProvider(productId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateProductCharacteristic({
    required int productId,
    required int characteristicId,
    required String name,
    required String value,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateProductCharacteristic(
        characteristicId: characteristicId,
        name: name,
        value: value,
      );
      ref.invalidate(adminProductCharacteristicsProvider(productId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteProductCharacteristic({
    required int productId,
    required int characteristicId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteProductCharacteristic(characteristicId);
      ref.invalidate(adminProductCharacteristicsProvider(productId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createCategory({
    required String name,
    required String description,
    int? parentCategoryId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.createCategory(
        name: name,
        description: description,
        parentCategoryId: parentCategoryId,
      );
      ref.invalidate(adminCategoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    int? parentCategoryId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateCategory(
        categoryId: categoryId,
        name: name,
        description: description,
        parentCategoryId: parentCategoryId,
      );
      ref.invalidate(adminCategoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteCategory(categoryId);
      ref.invalidate(adminCategoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createBrand({
    required String name,
    required String countryOfOrigin,
    required String contactInfo,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.createBrand(
        name: name,
        countryOfOrigin: countryOfOrigin,
        contactInfo: contactInfo,
      );
      ref.invalidate(adminBrandsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateBrand({
    required int brandId,
    required String name,
    required String countryOfOrigin,
    required String contactInfo,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateBrand(
        brandId: brandId,
        name: name,
        countryOfOrigin: countryOfOrigin,
        contactInfo: contactInfo,
      );
      ref.invalidate(adminBrandsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteBrand(int brandId) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteBrand(brandId);
      ref.invalidate(adminBrandsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> changeOrderStatus({
    required int orderId,
    required int statusId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.changeOrderStatus(orderId: orderId, statusId: statusId);
      ref.invalidate(adminOrdersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> changeUserRole({
    required int userId,
    required int roleId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.changeUserRole(userId: userId, roleId: roleId);
      ref.invalidate(adminUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> blockUser(int userId) async {
    state = const AsyncValue.loading();
    try {
      await repository.blockUser(userId);
      ref.invalidate(adminUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> unblockUser(int userId) async {
    state = const AsyncValue.loading();
    try {
      await repository.unblockUser(userId);
      ref.invalidate(adminUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteReview(reviewId);
      ref.invalidate(adminReviewsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createBackup() async {
    state = const AsyncValue.loading();
    try {
      await repository.createBackup();
      ref.invalidate(adminBackupsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> restoreBackup({String? filePath}) async {
    state = const AsyncValue.loading();
    try {
      await repository.restoreBackup(filePath: filePath);
      ref.invalidate(adminBackupsProvider);
      ref.invalidate(adminProductsProvider);
      ref.invalidate(adminCategoriesProvider);
      ref.invalidate(adminBrandsProvider);
      ref.invalidate(adminOrdersProvider);
      ref.invalidate(adminUsersProvider);
      ref.invalidate(adminReviewsProvider);
      ref.invalidate(adminIncomeStatsProvider);
      ref.invalidate(adminTopProductsStatsProvider);
      ref.invalidate(adminTopUsersStatsProvider);
      ref.invalidate(adminAuditLogProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
  return AdminController(
    ref: ref,
    repository: ref.read(adminRepositoryProvider),
  );
});