import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'package:server/src/auth/auth_handler.dart';
import 'package:server/src/auth/auth_service.dart';
import 'package:server/src/config/app_env.dart';
import 'package:server/src/database/database_service.dart';
import 'package:server/src/handlers/address_handler.dart';
import 'package:server/src/handlers/admin_handler.dart';
import 'package:server/src/handlers/brand_handler.dart';
import 'package:server/src/handlers/cart_handler.dart';
import 'package:server/src/handlers/category_handler.dart';
import 'package:server/src/handlers/compare_handler.dart';
import 'package:server/src/handlers/delivery_handler.dart';
import 'package:server/src/handlers/favorites_handler.dart';
import 'package:server/src/handlers/order_handler.dart';
import 'package:server/src/handlers/payment_handler.dart';
import 'package:server/src/handlers/product_handler.dart';
import 'package:server/src/handlers/profile_handler.dart';
import 'package:server/src/handlers/review_handler.dart';
import 'package:server/src/handlers/system_handler.dart';
import 'package:server/src/router/app_router.dart';
import 'package:server/src/services/email_service.dart';

Future<void> main() async {
  AppEnv.load();

  final database = DatabaseService();
  await database.open();

  final emailService = EmailService();

  final productHandler = ProductHandler(database);
  final compareHandler = CompareHandler(database);
  final categoryHandler = CategoryHandler(database);
  final brandHandler = BrandHandler(database);
  final deliveryHandler = DeliveryHandler(database);
  final paymentHandler = PaymentHandler(database);
  final addressHandler = AddressHandler(database);

  final authService = AuthService(database, emailService);
  final authHandler = AuthHandler(authService);

  final profileHandler = ProfileHandler(database);
  final favoritesHandler = FavoritesHandler(database);
  final cartHandler = CartHandler(database);
  final orderHandler = OrderHandler(database);
  final reviewHandler = ReviewHandler(database);
  final adminHandler = AdminHandler(database);
  final systemHandler = SystemHandler(database);

  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addHandler(
        buildRouter(
          productHandler: productHandler,
          compareHandler: compareHandler,
          categoryHandler: categoryHandler,
          brandHandler: brandHandler,
          deliveryHandler: deliveryHandler,
          paymentHandler: paymentHandler,
          addressHandler: addressHandler,
          authHandler: authHandler,
          authService: authService,
          profileHandler: profileHandler,
          favoritesHandler: favoritesHandler,
          cartHandler: cartHandler,
          orderHandler: orderHandler,
          reviewHandler: reviewHandler,
          adminHandler: adminHandler,
          systemHandler: systemHandler,
        ).call,
      );

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    AppEnv.serverPort,
  );

  print('Server started on http://localhost:${server.port}');
}