import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../auth/auth_handler.dart';
import '../auth/auth_middleware.dart';
import '../auth/auth_service.dart';
import '../handlers/address_handler.dart';
import '../handlers/admin_handler.dart';
import '../handlers/brand_handler.dart';
import '../handlers/cart_handler.dart';
import '../handlers/category_handler.dart';
import '../handlers/compare_handler.dart';
import '../handlers/delivery_handler.dart';
import '../handlers/favorites_handler.dart';
import '../handlers/order_handler.dart';
import '../handlers/payment_handler.dart';
import '../handlers/product_handler.dart';
import '../handlers/profile_handler.dart';
import '../handlers/review_handler.dart';
import '../handlers/system_handler.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
};

Middleware corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(
        headers: {
          ...response.headers,
          ..._corsHeaders,
        },
      );
    };
  };
}

Handler _authOnly(AuthService authService, Handler handler) {
  return const Pipeline()
      .addMiddleware((inner) => requireAuth(authService)(inner))
      .addHandler(handler);
}

Handler _adminOnly(AuthService authService, Handler handler) {
  return const Pipeline()
      .addMiddleware((inner) => requireAuth(authService)(inner))
      .addMiddleware((inner) => requireRole(['Администратор'])(inner))
      .addHandler(handler);
}

Router buildRouter({
  required ProductHandler productHandler,
  required CompareHandler compareHandler,
  required CategoryHandler categoryHandler,
  required BrandHandler brandHandler,
  required DeliveryHandler deliveryHandler,
  required PaymentHandler paymentHandler,
  required AddressHandler addressHandler,
  required AuthHandler authHandler,
  required AuthService authService,
  required ProfileHandler profileHandler,
  required FavoritesHandler favoritesHandler,
  required CartHandler cartHandler,
  required OrderHandler orderHandler,
  required ReviewHandler reviewHandler,
  required AdminHandler adminHandler,
  required SystemHandler systemHandler,
}) {
  final router = Router();

  router.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({'message': 'Server is running'}),
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );
  });

  // ===================== PUBLIC =====================

  router.get('/api/products', productHandler.getProducts);
  router.get('/api/products/<id|\\d+>', productHandler.getProductById);
  router.get('/api/compare', compareHandler.compareProducts);
  router.get('/api/categories', categoryHandler.getCategories);
  router.get('/api/brands', brandHandler.getBrands);
  router.get('/api/delivery-types', deliveryHandler.getDeliveryTypes);
  router.get('/api/payment-types', paymentHandler.getPaymentTypes);
  router.get(
    '/api/products/<productId|\\d+>/reviews',
    reviewHandler.getReviewsByProduct,
  );

  // ===================== AUTH =====================

  router.post('/api/auth/register', authHandler.register);
  router.post('/api/auth/login', authHandler.login);
  router.post('/api/auth/forgot-password', authHandler.forgotPassword);
  router.post('/api/auth/logout', authHandler.logout);
  router.get('/api/auth/me', _authOnly(authService, authHandler.me));

  // ===================== ADDRESSES =====================

  router.get(
    '/api/addresses',
    _authOnly(authService, addressHandler.getAddresses),
  );
  router.post(
    '/api/addresses',
    _authOnly(authService, addressHandler.createAddress),
  );

  router.patch('/api/addresses/<addressId|\\d+>',
      (Request request, String addressId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          addressHandler.updateAddress(authedRequest, addressId),
    );
    return handler(request);
  });

  router.delete('/api/addresses/<addressId|\\d+>',
      (Request request, String addressId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          addressHandler.deleteAddress(authedRequest, addressId),
    );
    return handler(request);
  });

  // ===================== PROFILE =====================

  router.get('/api/profile', _authOnly(authService, profileHandler.getProfile));
  router.put(
    '/api/profile',
    _authOnly(authService, profileHandler.updateProfile),
  );

  // ===================== FAVORITES =====================

  router.get(
    '/api/favorites',
    _authOnly(authService, favoritesHandler.getFavorites),
  );

  router.post('/api/favorites/<productId|\\d+>',
      (Request request, String productId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          favoritesHandler.addFavorite(authedRequest, productId),
    );
    return handler(request);
  });

  router.delete('/api/favorites/<productId|\\d+>',
      (Request request, String productId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          favoritesHandler.removeFavorite(authedRequest, productId),
    );
    return handler(request);
  });

  // ===================== CART =====================

  router.get('/api/cart', _authOnly(authService, cartHandler.getCart));
  router.post('/api/cart', _authOnly(authService, cartHandler.addToCart));

  router.patch('/api/cart/<itemId|\\d+>', (Request request, String itemId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          cartHandler.updateCartItem(authedRequest, itemId),
    );
    return handler(request);
  });

  router.delete('/api/cart/<itemId|\\d+>', (Request request, String itemId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          cartHandler.removeCartItem(authedRequest, itemId),
    );
    return handler(request);
  });

  // ===================== ORDERS =====================

  router.get('/api/orders', _authOnly(authService, orderHandler.getOrders));
  router.post('/api/orders', _authOnly(authService, orderHandler.createOrder));

  router.get('/api/orders/<orderId|\\d+>', (Request request, String orderId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          orderHandler.getOrderById(authedRequest, orderId),
    );
    return handler(request);
  });

  router.patch('/api/orders/<orderId|\\d+>/cancel',
      (Request request, String orderId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          orderHandler.cancelOrder(authedRequest, orderId),
    );
    return handler(request);
  });

  // ===================== REVIEWS =====================

  router.post('/api/products/<productId|\\d+>/reviews',
      (Request request, String productId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          reviewHandler.createReview(authedRequest, productId),
    );
    return handler(request);
  });

  router.patch('/api/reviews/<reviewId|\\d+>',
      (Request request, String reviewId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          reviewHandler.updateReview(authedRequest, reviewId),
    );
    return handler(request);
  });

  router.delete('/api/reviews/<reviewId|\\d+>',
      (Request request, String reviewId) {
    final handler = _authOnly(
      authService,
      (Request authedRequest) =>
          reviewHandler.deleteReview(authedRequest, reviewId),
    );
    return handler(request);
  });

  // ===================== ADMIN: PRODUCTS =====================

  router.get(
    '/api/admin/products',
    _adminOnly(authService, adminHandler.getAdminProducts),
  );
  router.post(
    '/api/admin/products',
    _adminOnly(authService, adminHandler.addProduct),
  );

  router.patch('/api/admin/products/<productId|\\d+>',
      (Request request, String productId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.updateProduct(authedRequest, productId),
    );
    return handler(request);
  });

  router.delete('/api/admin/products/<productId|\\d+>',
      (Request request, String productId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.deleteProduct(authedRequest, productId),
    );
    return handler(request);
  });

  // ===================== ADMIN: PRODUCT CHARACTERISTICS =====================

  router.get('/api/admin/products/<productId|\\d+>/characteristics',
      (Request request, String productId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.getProductCharacteristicsAdmin(
        authedRequest,
        productId,
      ),
    );
    return handler(request);
  });

  router.post('/api/admin/products/<productId|\\d+>/characteristics',
      (Request request, String productId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.createProductCharacteristic(
        authedRequest,
        productId,
      ),
    );
    return handler(request);
  });

  router.patch('/api/admin/characteristics/<characteristicId|\\d+>',
      (Request request, String characteristicId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.updateProductCharacteristic(
        authedRequest,
        characteristicId,
      ),
    );
    return handler(request);
  });

  router.delete('/api/admin/characteristics/<characteristicId|\\d+>',
      (Request request, String characteristicId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.deleteProductCharacteristic(
        authedRequest,
        characteristicId,
      ),
    );
    return handler(request);
  });

  // ===================== ADMIN: CATEGORIES =====================

  router.post(
    '/api/admin/categories',
    _adminOnly(authService, adminHandler.createCategory),
  );

  router.patch('/api/admin/categories/<categoryId|\\d+>',
      (Request request, String categoryId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.updateCategory(authedRequest, categoryId),
    );
    return handler(request);
  });

  router.delete('/api/admin/categories/<categoryId|\\d+>',
      (Request request, String categoryId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.deleteCategory(authedRequest, categoryId),
    );
    return handler(request);
  });

  // ===================== ADMIN: BRANDS =====================

  router.post(
    '/api/admin/brands',
    _adminOnly(authService, adminHandler.createBrand),
  );

  router.patch('/api/admin/brands/<brandId|\\d+>',
      (Request request, String brandId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.updateBrand(authedRequest, brandId),
    );
    return handler(request);
  });

  router.delete('/api/admin/brands/<brandId|\\d+>',
      (Request request, String brandId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.deleteBrand(authedRequest, brandId),
    );
    return handler(request);
  });

  // ===================== ADMIN: ORDERS =====================

  router.get(
    '/api/admin/orders',
    _adminOnly(authService, adminHandler.getAdminOrders),
  );

  router.get('/api/admin/orders/<orderId|\\d+>',
      (Request request, String orderId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.getAdminOrderById(authedRequest, orderId),
    );
    return handler(request);
  });

  router.patch('/api/admin/orders/<orderId|\\d+>/status',
      (Request request, String orderId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.changeOrderStatus(authedRequest, orderId),
    );
    return handler(request);
  });

  // ===================== ADMIN: USERS =====================

  router.get(
    '/api/admin/users',
    _adminOnly(authService, adminHandler.getAdminUsers),
  );

  router.patch('/api/admin/users/<userId|\\d+>/role',
      (Request request, String userId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.changeUserRole(authedRequest, userId),
    );
    return handler(request);
  });

  router.patch('/api/admin/users/<userId|\\d+>/block',
      (Request request, String userId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.setUserBlocked(
        authedRequest,
        userId,
        isBlocked: true,
      ),
    );
    return handler(request);
  });

  router.patch('/api/admin/users/<userId|\\d+>/unblock',
      (Request request, String userId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.setUserBlocked(
        authedRequest,
        userId,
        isBlocked: false,
      ),
    );
    return handler(request);
  });

  // ===================== ADMIN: REVIEWS =====================

  router.get(
    '/api/admin/reviews',
    _adminOnly(authService, adminHandler.getAdminReviews),
  );

  router.delete('/api/admin/reviews/<reviewId|\\d+>',
      (Request request, String reviewId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.deleteReviewAdmin(authedRequest, reviewId),
    );
    return handler(request);
  });

  // ===================== ADMIN: STATS =====================

  router.get(
    '/api/admin/stats/income',
    _adminOnly(authService, adminHandler.getIncomeStats),
  );
  router.get(
    '/api/admin/stats/top-products',
    _adminOnly(authService, adminHandler.getTopProductsStats),
  );
  router.get(
    '/api/admin/stats/top-users',
    _adminOnly(authService, adminHandler.getTopUsersStats),
  );

  router.get('/api/admin/stats/users/<userId|\\d+>/avg-check',
      (Request request, String userId) {
    final handler = _adminOnly(
      authService,
      (Request authedRequest) =>
          adminHandler.getUserAvgCheckStats(authedRequest, userId),
    );
    return handler(request);
  });

  // ===================== ADMIN: AUDIT =====================

  router.get(
    '/api/admin/audit',
    _adminOnly(authService, adminHandler.getAuditLog),
  );

  // ===================== ADMIN: LOOKUPS =====================

  router.get(
    '/api/admin/order-statuses',
    _adminOnly(authService, adminHandler.getOrderStatuses),
  );

  router.get(
    '/api/admin/roles',
    _adminOnly(authService, adminHandler.getRoles),
  );

  // ===================== ADMIN: SYSTEM =====================

  router.get(
    '/api/admin/export/orders',
    _adminOnly(authService, systemHandler.exportOrdersCsv),
  );

  router.get(
    '/api/admin/backups',
    _adminOnly(authService, systemHandler.listBackups),
  );

  router.post(
    '/api/admin/backup',
    _adminOnly(authService, systemHandler.createBackup),
  );

  router.post(
    '/api/admin/restore',
    _adminOnly(authService, systemHandler.restoreBackup),
  );

  return router;
}