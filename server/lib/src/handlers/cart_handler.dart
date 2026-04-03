import 'package:shelf/shelf.dart';

import '../auth/auth_middleware.dart';
import '../common/json_response.dart';
import '../common/request_body.dart';
import '../database/database_service.dart';

class CartHandler {
  final DatabaseService database;

  CartHandler(this.database);

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw Exception('Не удалось преобразовать "$value" в int');
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw Exception('Не удалось преобразовать "$value" в double');
  }

  Future<Response> getCart(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rows = await database.connection.execute(
        r'''
        SELECT
          ci.ID_CartItem AS cart_item_id,
          ci.Quantity AS quantity,
          ci.AddedDate AS added_date,
          p.ID_Product AS product_id,
          p.ProductName AS product_name,
          p.Model AS model,
          p.Description AS description,
          p.Price AS price,
          p.StockQuantity AS stock_quantity,
          p.ImageURL AS image_url,
          p.WarrantyPeriod AS warranty_period,
          b.ID_Brand AS brand_id,
          b.BrandName AS brand_name,
          c.ID_Category AS category_id,
          c.CategoryName AS category_name
        FROM CartItems ci
        JOIN Products p ON p.ID_Product = ci.Product_ID
        JOIN Brands b ON b.ID_Brand = p.Brand_ID
        JOIN Categories c ON c.ID_Category = p.Category_ID
        WHERE ci.User_ID = $1
        ORDER BY ci.AddedDate DESC
        ''',
        parameters: [user.userId],
      );

      double totalAmount = 0;

      final items = rows.map((row) {
        final map = row.toColumnMap();
        final price = _toDouble(map['price']);
        final quantity = _toInt(map['quantity']);
        final itemTotal = price * quantity;
        totalAmount += itemTotal;

        return {
          'cartItemId': _toInt(map['cart_item_id']),
          'quantity': quantity,
          'addedDate': map['added_date']?.toString(),
          'itemTotal': itemTotal,
          'product': {
            'id': _toInt(map['product_id']),
            'name': map['product_name'],
            'model': map['model'],
            'description': map['description'],
            'price': price,
            'stockQuantity': _toInt(map['stock_quantity']),
            'imageUrl': map['image_url'],
            'warrantyPeriod': map['warranty_period'],
            'brand': {
              'id': _toInt(map['brand_id']),
              'name': map['brand_name'],
            },
            'category': {
              'id': _toInt(map['category_id']),
              'name': map['category_name'],
            },
          },
        };
      }).toList();

      return jsonOk({
        'items': items,
        'totalAmount': totalAmount,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки корзины',
        details: e.toString(),
      );
    }
  }

  Future<Response> addToCart(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final productId = requireInt(body, 'productId', min: 1);
      final quantityToAdd = requireInt(body, 'quantity', min: 1);

      final productRows = await database.connection.execute(
        r'''
        SELECT
          ID_Product AS product_id,
          StockQuantity AS stock_quantity
        FROM Products
        WHERE ID_Product = $1
        LIMIT 1
        ''',
        parameters: [productId],
      );

      if (productRows.isEmpty) {
        return jsonNotFound('Товар не найден');
      }

      final productMap = productRows.first.toColumnMap();
      final stockQuantity = _toInt(productMap['stock_quantity']);

      final currentRows = await database.connection.execute(
        r'''
        SELECT Quantity AS quantity
        FROM CartItems
        WHERE User_ID = $1 AND Product_ID = $2
        LIMIT 1
        ''',
        parameters: [user.userId, productId],
      );

      final currentQuantity = currentRows.isEmpty
          ? 0
          : _toInt(currentRows.first.toColumnMap()['quantity']);

      final newQuantity = currentQuantity + quantityToAdd;

      if (newQuantity > stockQuantity) {
        return jsonBadRequest(
          'Недостаточно товара на складе. Доступно: $stockQuantity',
        );
      }

      await database.connection.execute(
        r'''
        INSERT INTO CartItems (User_ID, Product_ID, Quantity)
        VALUES ($1, $2, $3)
        ON CONFLICT (User_ID, Product_ID)
        DO UPDATE SET
          Quantity = EXCLUDED.Quantity + CartItems.Quantity,
          AddedDate = CURRENT_TIMESTAMP
        ''',
        parameters: [user.userId, productId, quantityToAdd],
      );

      return jsonCreated({'message': 'Товар добавлен в корзину'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось добавить товар в корзину',
        details: e.toString(),
      );
    }
  }

  Future<Response> updateCartItem(Request request, String itemIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final itemId = int.parse(itemIdRaw);

      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);
      final quantity = requireInt(body, 'quantity', min: 1);

      final rows = await database.connection.execute(
        r'''
        SELECT
          ci.ID_CartItem AS cart_item_id,
          p.StockQuantity AS stock_quantity
        FROM CartItems ci
        JOIN Products p ON p.ID_Product = ci.Product_ID
        WHERE ci.ID_CartItem = $1 AND ci.User_ID = $2
        LIMIT 1
        ''',
        parameters: [itemId, user.userId],
      );

      if (rows.isEmpty) {
        return jsonNotFound('Позиция корзины не найдена');
      }

      final map = rows.first.toColumnMap();
      final stockQuantity = _toInt(map['stock_quantity']);

      if (quantity > stockQuantity) {
        return jsonBadRequest(
          'Недостаточно товара на складе. Доступно: $stockQuantity',
        );
      }

      await database.connection.execute(
        r'''
        UPDATE CartItems
        SET Quantity = $1
        WHERE ID_CartItem = $2 AND User_ID = $3
        ''',
        parameters: [quantity, itemId, user.userId],
      );

      return jsonOk({'message': 'Количество товара обновлено'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось обновить корзину',
        details: e.toString(),
      );
    }
  }

  Future<Response> removeCartItem(Request request, String itemIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final itemId = int.parse(itemIdRaw);

      final result = await database.connection.execute(
        r'''
        DELETE FROM CartItems
        WHERE ID_CartItem = $1 AND User_ID = $2
        ''',
        parameters: [itemId, user.userId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Позиция корзины не найдена');
      }

      return jsonOk({'message': 'Товар удалён из корзины'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось удалить товар из корзины',
        details: e.toString(),
      );
    }
  }
}