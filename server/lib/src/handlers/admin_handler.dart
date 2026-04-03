import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';

import '../auth/auth_middleware.dart';
import '../common/json_response.dart';
import '../common/request_body.dart';
import '../database/database_service.dart';

class AdminHandler {
  final DatabaseService database;

  AdminHandler(this.database);

  Future<void> _setAuditAccount(Session session, int accountId) async {
    await session.execute(
      r'''
      SELECT set_config('app.current_account_id', $1, true)
      ''',
      parameters: [accountId.toString()],
    );
  }

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

  int _queryInt(Request request, String name, int defaultValue) {
    final raw = request.url.queryParameters[name];
    if (raw == null || raw.trim().isEmpty) {
      return defaultValue;
    }
    return int.tryParse(raw) ?? defaultValue;
  }

  Future<Response> getOrderStatuses(Request request) async {
    try {
      final rows = await database.connection.execute(
        r'''
        SELECT
          ID_Status AS id,
          StatusName AS name
        FROM OrderStatuses
        ORDER BY ID_Status
        ''',
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': _toInt(map['id']),
          'name': map['name'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки статусов заказа',
        details: e.toString(),
      );
    }
  }

  Future<Response> getRoles(Request request) async {
    try {
      final rows = await database.connection.execute(
        r'''
        SELECT
          ID_Role AS id,
          RoleName AS name
        FROM Roles
        ORDER BY ID_Role
        ''',
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': _toInt(map['id']),
          'name': map['name'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки ролей',
        details: e.toString(),
      );
    }
  }

  Future<Response> getProductCharacteristicsAdmin(
    Request request,
    String productIdRaw,
  ) async {
    try {
      final productId = int.parse(productIdRaw);

      final rows = await database.connection.execute(
        r'''
        SELECT
          ID_Characteristic AS characteristic_id,
          CharacteristicName AS characteristic_name,
          CharacteristicValue AS characteristic_value
        FROM ProductCharacteristics
        WHERE Product_ID = $1
        ORDER BY ID_Characteristic
        ''',
        parameters: [productId],
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': _toInt(map['characteristic_id']),
          'name': map['characteristic_name'],
          'value': map['characteristic_value'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки характеристик товара',
        details: e.toString(),
      );
    }
  }

  Future<Response> createProductCharacteristic(
    Request request,
    String productIdRaw,
  ) async {
    try {
      final productId = int.parse(productIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final name = requireString(body, 'name');
      final value = requireString(body, 'value');

      await database.connection.execute(
        r'''
        INSERT INTO ProductCharacteristics (
          CharacteristicName,
          CharacteristicValue,
          Product_ID
        )
        VALUES ($1, $2, $3)
        ''',
        parameters: [name, value, productId],
      );

      return jsonCreated({'message': 'Характеристика добавлена'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось добавить характеристику',
        details: e.toString(),
      );
    }
  }

  Future<Response> updateProductCharacteristic(
    Request request,
    String characteristicIdRaw,
  ) async {
    try {
      final characteristicId = int.parse(characteristicIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final name = requireString(body, 'name');
      final value = requireString(body, 'value');

      final result = await database.connection.execute(
        r'''
        UPDATE ProductCharacteristics
        SET
          CharacteristicName = $1,
          CharacteristicValue = $2
        WHERE ID_Characteristic = $3
        ''',
        parameters: [name, value, characteristicId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Характеристика не найдена');
      }

      return jsonOk({'message': 'Характеристика обновлена'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось обновить характеристику',
        details: e.toString(),
      );
    }
  }

  Future<Response> deleteProductCharacteristic(
    Request request,
    String characteristicIdRaw,
  ) async {
    try {
      final characteristicId = int.parse(characteristicIdRaw);

      final result = await database.connection.execute(
        r'''
        DELETE FROM ProductCharacteristics
        WHERE ID_Characteristic = $1
        ''',
        parameters: [characteristicId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Характеристика не найдена');
      }

      return jsonOk({'message': 'Характеристика удалена'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось удалить характеристику',
        details: e.toString(),
      );
    }
  }

  Future<Response> getAdminProducts(Request request) async {
    try {
      final rows = await database.connection.execute(
        '''
        SELECT
          "Код товара" AS id,
          "Наименование товара" AS name,
          "Бренд" AS brand,
          "Категория" AS category,
          "Модель" AS model,
          "Цена" AS price,
          "Количество на складе" AS stock_quantity
        FROM ProductsView
        ORDER BY "Код товара"
        ''',
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': _toInt(map['id']),
          'name': map['name'],
          'brand': map['brand'],
          'category': map['category'],
          'model': map['model'],
          'price': _toDouble(map['price']),
          'stockQuantity': _toInt(map['stock_quantity']),
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки списка товаров',
        details: e.toString(),
      );
    }
  }

  Future<Response> addProduct(Request request) async {
    try {
      final admin = currentUser(request);
      if (admin == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final productName = requireString(body, 'productName');
      final description = requireString(body, 'description', allowEmpty: true);
      final model = requireString(body, 'model');
      final price = requireInt(body, 'price', min: 1);
      final stockQuantity = requireInt(body, 'stockQuantity', min: 0);
      final imageUrl = requireString(body, 'imageUrl', allowEmpty: true);
      final warrantyPeriod = requireString(
        body,
        'warrantyPeriod',
        allowEmpty: true,
      );
      final brandId = requireInt(body, 'brandId', min: 1);
      final categoryId = requireInt(body, 'categoryId', min: 1);

      late final int createdProductId;

      await database.connection.runTx((tx) async {
        await _setAuditAccount(tx, admin.accountId);

        await tx.execute(
          r'''
          CALL AddProduct($1, $2, $3, $4, $5, $6, $7, $8, $9)
          ''',
          parameters: [
            productName,
            description.isEmpty ? null : description,
            model,
            price,
            stockQuantity,
            imageUrl.isEmpty ? null : imageUrl,
            warrantyPeriod.isEmpty ? null : warrantyPeriod,
            brandId,
            categoryId,
          ],
        );

        final createdRows = await tx.execute(
          r'''
          SELECT ID_Product AS product_id
          FROM Products
          WHERE ProductName = $1
            AND Model = $2
            AND Price = $3
            AND StockQuantity = $4
            AND Brand_ID = $5
            AND Category_ID = $6
            AND Description IS NOT DISTINCT FROM $7
            AND ImageURL IS NOT DISTINCT FROM $8
            AND WarrantyPeriod IS NOT DISTINCT FROM $9
          ORDER BY ID_Product DESC
          LIMIT 1
          ''',
          parameters: [
            productName,
            model,
            price,
            stockQuantity,
            brandId,
            categoryId,
            description.isEmpty ? null : description,
            imageUrl.isEmpty ? null : imageUrl,
            warrantyPeriod.isEmpty ? null : warrantyPeriod,
          ],
        );

        if (createdRows.isEmpty) {
          throw Exception('Товар добавлен, но не удалось получить его ID');
        }

        createdProductId = _toInt(
          createdRows.first.toColumnMap()['product_id'],
        );
      });

      return jsonCreated({
        'message': 'Товар успешно добавлен',
        'productId': createdProductId,
      });
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> updateProduct(Request request, String productIdRaw) async {
    try {
      final admin = currentUser(request);
      if (admin == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final productId = int.parse(productIdRaw);

      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final productName = requireString(body, 'productName');
      final description = requireString(body, 'description', allowEmpty: true);
      final model = requireString(body, 'model');
      final price = requireInt(body, 'price', min: 1);
      final stockQuantity = requireInt(body, 'stockQuantity', min: 0);
      final imageUrl = requireString(body, 'imageUrl', allowEmpty: true);
      final warrantyPeriod = requireString(body, 'warrantyPeriod', allowEmpty: true);
      final brandId = requireInt(body, 'brandId', min: 1);
      final categoryId = requireInt(body, 'categoryId', min: 1);

      await database.connection.runTx((tx) async {
        await _setAuditAccount(tx, admin.accountId);

        final exists = await tx.execute(
          r'''
          SELECT 1
          FROM Products
          WHERE ID_Product = $1
          LIMIT 1
          ''',
          parameters: [productId],
        );

        if (exists.isEmpty) {
          throw Exception('Товар не найден');
        }

        await tx.execute(
          r'''
          UPDATE Products
          SET
            ProductName = $1,
            Description = $2,
            Model = $3,
            Price = $4,
            StockQuantity = $5,
            ImageURL = $6,
            WarrantyPeriod = $7,
            Brand_ID = $8,
            Category_ID = $9
          WHERE ID_Product = $10
          ''',
          parameters: [
            productName,
            description.isEmpty ? null : description,
            model,
            price,
            stockQuantity,
            imageUrl.isEmpty ? null : imageUrl,
            warrantyPeriod.isEmpty ? null : warrantyPeriod,
            brandId,
            categoryId,
            productId,
          ],
        );
      });

      return jsonOk({'message': 'Товар успешно обновлён'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> deleteProduct(Request request, String productIdRaw) async {
    try {
      final admin = currentUser(request);
      if (admin == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final productId = int.parse(productIdRaw);

      await database.connection.runTx((tx) async {
        await _setAuditAccount(tx, admin.accountId);

        final result = await tx.execute(
          r'''
          DELETE FROM Products
          WHERE ID_Product = $1
          ''',
          parameters: [productId],
        );

        if (result.affectedRows == 0) {
          throw Exception('Товар не найден');
        }
      });

      return jsonOk({'message': 'Товар удалён'});
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> createCategory(Request request) async {
    try {
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final name = requireString(body, 'name');
      final description = requireString(body, 'description', allowEmpty: true);
      final parentCategoryId = body['parentCategoryId'];

      await database.connection.execute(
        r'''
        INSERT INTO Categories (CategoryName, CategoryDescription, ParentCategory_ID)
        VALUES ($1, $2, $3)
        ''',
        parameters: [
          name,
          description.isEmpty ? null : description,
          parentCategoryId,
        ],
      );

      return jsonCreated({'message': 'Категория успешно добавлена'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось добавить категорию',
        details: e.toString(),
      );
    }
  }

  Future<Response> updateCategory(Request request, String categoryIdRaw) async {
    try {
      final categoryId = int.parse(categoryIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final name = requireString(body, 'name');
      final description = requireString(body, 'description', allowEmpty: true);
      final parentCategoryId = body['parentCategoryId'];

      final result = await database.connection.execute(
        r'''
        UPDATE Categories
        SET
          CategoryName = $1,
          CategoryDescription = $2,
          ParentCategory_ID = $3
        WHERE ID_Category = $4
        ''',
        parameters: [
          name,
          description.isEmpty ? null : description,
          parentCategoryId,
          categoryId,
        ],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Категория не найдена');
      }

      return jsonOk({'message': 'Категория успешно обновлена'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось обновить категорию',
        details: e.toString(),
      );
    }
  }

  Future<Response> deleteCategory(Request request, String categoryIdRaw) async {
    try {
      final categoryId = int.parse(categoryIdRaw);

      final result = await database.connection.execute(
        r'''
        DELETE FROM Categories
        WHERE ID_Category = $1
        ''',
        parameters: [categoryId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Категория не найдена');
      }

      return jsonOk({'message': 'Категория удалена'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось удалить категорию',
        details: e.toString(),
      );
    }
  }

  Future<Response> createBrand(Request request) async {
    try {
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final name = requireString(body, 'name');
      final countryOfOrigin = requireString(body, 'countryOfOrigin');
      final contactInfo = requireString(body, 'contactInfo', allowEmpty: true);

      await database.connection.execute(
        r'''
        INSERT INTO Brands (BrandName, CountryOfOrigin, ContactInfo)
        VALUES ($1, $2, $3)
        ''',
        parameters: [
          name,
          countryOfOrigin,
          contactInfo.isEmpty ? null : contactInfo,
        ],
      );

      return jsonCreated({'message': 'Бренд успешно добавлен'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось добавить бренд',
        details: e.toString(),
      );
    }
  }

  Future<Response> updateBrand(Request request, String brandIdRaw) async {
    try {
      final brandId = int.parse(brandIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final name = requireString(body, 'name');
      final countryOfOrigin = requireString(body, 'countryOfOrigin');
      final contactInfo = requireString(body, 'contactInfo', allowEmpty: true);

      final result = await database.connection.execute(
        r'''
        UPDATE Brands
        SET
          BrandName = $1,
          CountryOfOrigin = $2,
          ContactInfo = $3
        WHERE ID_Brand = $4
        ''',
        parameters: [
          name,
          countryOfOrigin,
          contactInfo.isEmpty ? null : contactInfo,
          brandId,
        ],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Бренд не найден');
      }

      return jsonOk({'message': 'Бренд успешно обновлён'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось обновить бренд',
        details: e.toString(),
      );
    }
  }

  Future<Response> deleteBrand(Request request, String brandIdRaw) async {
    try {
      final brandId = int.parse(brandIdRaw);

      final result = await database.connection.execute(
        r'''
        DELETE FROM Brands
        WHERE ID_Brand = $1
        ''',
        parameters: [brandId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Бренд не найден');
      }

      return jsonOk({'message': 'Бренд удалён'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось удалить бренд',
        details: e.toString(),
      );
    }
  }

  Future<Response> getAdminOrders(Request request) async {
    try {
      final rows = await database.connection.execute(
        '''
        SELECT
          "Код заказа" AS id,
          "Дата заказа" AS order_date,
          "Покупатель" AS customer,
          "Статус" AS status,
          "Способ доставки" AS delivery_type,
          "Способ оплаты" AS payment_type,
          "Адрес доставки" AS delivery_address,
          "Итоговая сумма" AS total_amount
        FROM OrdersView
        ORDER BY "Дата заказа" DESC
        ''',
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': _toInt(map['id']),
          'orderDate': map['order_date']?.toString(),
          'customer': map['customer'],
          'status': map['status'],
          'deliveryType': map['delivery_type'],
          'paymentType': map['payment_type'],
          'deliveryAddress': map['delivery_address'],
          'totalAmount': _toDouble(map['total_amount']),
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки списка заказов',
        details: e.toString(),
      );
    }
  }

  Future<Response> getAdminOrderById(Request request, String orderIdRaw) async {
    try {
      final orderId = int.parse(orderIdRaw);

      final orderRows = await database.connection.execute(
        r'''
        SELECT
          o.ID_Order AS order_id,
          o.OrderDate AS order_date,
          o.TotalAmount AS total_amount,
          o.OrderComment AS order_comment,
          s.StatusName AS status_name,
          d.TypeName AS delivery_type,
          p.TypeName AS payment_type,
          u.LastName || ' ' || u.FirstName || ' ' || COALESCE(u.Patronymic, '') AS customer_name
        FROM Orders o
        JOIN OrderStatuses s ON s.ID_Status = o.Status_ID
        JOIN DeliveryTypes d ON d.ID_DeliveryType = o.DeliveryType_ID
        JOIN PaymentTypes p ON p.ID_PaymentType = o.PaymentType_ID
        JOIN Users u ON u.ID_User = o.User_ID
        WHERE o.ID_Order = $1
        LIMIT 1
        ''',
        parameters: [orderId],
      );

      if (orderRows.isEmpty) {
        return jsonNotFound('Заказ не найден');
      }

      final detailsRows = await database.connection.execute(
        r'''
        SELECT
          "Код позиции" AS order_detail_id,
          "Товар" AS product_name,
          "Количество" AS quantity,
          "Цена за единицу" AS unit_price,
          "Сумма по позиции" AS total_price
        FROM OrderDetailsView
        WHERE "Код заказа" = $1
        ORDER BY "Код позиции"
        ''',
        parameters: [orderId],
      );

      final orderMap = orderRows.first.toColumnMap();

      final items = detailsRows.map((row) {
        final map = row.toColumnMap();
        return {
          'orderDetailId': _toInt(map['order_detail_id']),
          'productName': map['product_name'],
          'quantity': _toInt(map['quantity']),
          'unitPrice': _toDouble(map['unit_price']),
          'totalPrice': _toDouble(map['total_price']),
        };
      }).toList();

      return jsonOk({
        'id': _toInt(orderMap['order_id']),
        'orderDate': orderMap['order_date']?.toString(),
        'customer': orderMap['customer_name'],
        'status': orderMap['status_name'],
        'deliveryType': orderMap['delivery_type'],
        'paymentType': orderMap['payment_type'],
        'totalAmount': _toDouble(orderMap['total_amount']),
        'orderComment': orderMap['order_comment'],
        'items': items,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки заказа',
        details: e.toString(),
      );
    }
  }

  Future<Response> changeOrderStatus(Request request, String orderIdRaw) async {
    try {
      final admin = currentUser(request);
      if (admin == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final orderId = int.parse(orderIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);
      final statusId = requireInt(body, 'statusId', min: 1);

      await database.connection.runTx((tx) async {
        await _setAuditAccount(tx, admin.accountId);

        await tx.execute(
          r'''
          CALL ChangeOrderStatus($1, $2, $3)
          ''',
          parameters: [orderId, statusId, admin.accountId],
        );
      });

      return jsonOk({'message': 'Статус заказа успешно изменён'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> getAdminUsers(Request request) async {
    try {
      final rows = await database.connection.execute(
        '''
        SELECT
          "Код пользователя" AS user_id,
          "Фамилия" AS last_name,
          "Имя" AS first_name,
          "Электронная почта" AS email,
          "Роль" AS role,
          "Заблокирован" AS is_blocked
        FROM UsersAccountsView
        ORDER BY "Код пользователя"
        ''',
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'userId': _toInt(map['user_id']),
          'lastName': map['last_name'],
          'firstName': map['first_name'],
          'email': map['email'],
          'role': map['role'],
          'isBlocked': map['is_blocked'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки списка пользователей',
        details: e.toString(),
      );
    }
  }

  Future<Response> changeUserRole(Request request, String userIdRaw) async {
    try {
      final admin = currentUser(request);
      if (admin == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final userId = int.parse(userIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);
      final roleId = requireInt(body, 'roleId', min: 1);

      await database.connection.runTx((tx) async {
        await _setAuditAccount(tx, admin.accountId);

        final rows = await tx.execute(
          r'''
          SELECT a.ID_Account AS account_id
          FROM Users u
          JOIN Accounts a ON a.ID_Account = u.Account_ID
          WHERE u.ID_User = $1
          LIMIT 1
          ''',
          parameters: [userId],
        );

        if (rows.isEmpty) {
          throw Exception('Пользователь не найден');
        }

        final accountId = _toInt(rows.first.toColumnMap()['account_id']);

        await tx.execute(
          r'''
          UPDATE Accounts
          SET Role_ID = $1
          WHERE ID_Account = $2
          ''',
          parameters: [roleId, accountId],
        );
      });

      return jsonOk({'message': 'Роль пользователя успешно изменена'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> setUserBlocked(
    Request request,
    String userIdRaw, {
    required bool isBlocked,
  }) async {
    try {
      final admin = currentUser(request);
      if (admin == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final userId = int.parse(userIdRaw);

      await database.connection.runTx((tx) async {
        await _setAuditAccount(tx, admin.accountId);

        final rows = await tx.execute(
          r'''
          SELECT a.ID_Account AS account_id
          FROM Users u
          JOIN Accounts a ON a.ID_Account = u.Account_ID
          WHERE u.ID_User = $1
          LIMIT 1
          ''',
          parameters: [userId],
        );

        if (rows.isEmpty) {
          throw Exception('Пользователь не найден');
        }

        final accountId = _toInt(rows.first.toColumnMap()['account_id']);

        await tx.execute(
          r'''
          UPDATE Accounts
          SET IsBlocked = $1
          WHERE ID_Account = $2
          ''',
          parameters: [isBlocked, accountId],
        );
      });

      return jsonOk({
        'message': isBlocked
            ? 'Пользователь заблокирован'
            : 'Пользователь разблокирован',
      });
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> getAdminReviews(Request request) async {
    try {
      final rows = await database.connection.execute(
        r'''
        SELECT
          r.ID_Review AS review_id,
          r.Rating AS rating,
          r.Comment AS comment,
          r.ReviewDate AS review_date,
          pr.ProductName AS product_name,
          u.LastName || ' ' || u.FirstName || ' ' || COALESCE(u.Patronymic, '') AS author_name
        FROM Reviews r
        JOIN Products pr ON pr.ID_Product = r.Product_ID
        JOIN Users u ON u.ID_User = r.User_ID
        ORDER BY r.ReviewDate DESC
        ''',
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'reviewId': _toInt(map['review_id']),
          'rating': _toInt(map['rating']),
          'comment': map['comment'],
          'reviewDate': map['review_date']?.toString(),
          'productName': map['product_name'],
          'authorName': map['author_name'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки отзывов',
        details: e.toString(),
      );
    }
  }

  Future<Response> deleteReviewAdmin(Request request, String reviewIdRaw) async {
    try {
      final admin = currentUser(request);
      if (admin == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final reviewId = int.parse(reviewIdRaw);

      await database.connection.runTx((tx) async {
        await _setAuditAccount(tx, admin.accountId);

        final result = await tx.execute(
          r'''
          DELETE FROM Reviews
          WHERE ID_Review = $1
          ''',
          parameters: [reviewId],
        );

        if (result.affectedRows == 0) {
          throw Exception('Отзыв не найден');
        }
      });

      return jsonOk({'message': 'Отзыв удалён'});
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> getIncomeStats(Request request) async {
    try {
      final days = _queryInt(request, 'days', 30);

      final rows = await database.connection.execute(
        r'''
        SELECT get_income_period($1) AS income
        ''',
        parameters: [days],
      );

      return jsonOk({
        'days': days,
        'income': _toDouble(rows.first.toColumnMap()['income']),
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки статистики дохода',
        details: e.toString(),
      );
    }
  }

  Future<Response> getTopProductsStats(Request request) async {
    try {
      final days = _queryInt(request, 'days', 30);
      final limit = _queryInt(request, 'limit', 5);

      final periodRows = await database.connection.execute(
        r'''
        SELECT *
        FROM get_top_products_period($1, $2)
        ''',
        parameters: [days, limit],
      );

      final periodResult = periodRows.map((row) {
        final map = row.toColumnMap();
        return {
          'productId': _toInt(map['product_id']),
          'productName': map['product_name'],
          'totalSold': _toInt(map['total_sold']),
        };
      }).toList();

      final topViewRows = await database.connection.execute(
        '''
        SELECT
          "Наименование товара" AS product_name,
          "Количество отзывов" AS review_count,
          "Средняя оценка" AS average_rating
        FROM TopProductsView
        ''',
      );

      final reviewTop = topViewRows.map((row) {
        final map = row.toColumnMap();
        return {
          'productName': map['product_name'],
          'reviewCount': _toInt(map['review_count']),
          'averageRating': map['average_rating'] == null
              ? null
              : _toDouble(map['average_rating']),
        };
      }).toList();

      return jsonOk({
        'period': {
          'days': days,
          'limit': limit,
          'items': periodResult,
        },
        'byReviews': reviewTop,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки статистики товаров',
        details: e.toString(),
      );
    }
  }

  Future<Response> getTopUsersStats(Request request) async {
    try {
      final days = _queryInt(request, 'days', 30);
      final limit = _queryInt(request, 'limit', 5);

      final periodRows = await database.connection.execute(
        r'''
        SELECT *
        FROM get_top_users_period($1, $2)
        ''',
        parameters: [days, limit],
      );

      final result = periodRows.map((row) {
        final map = row.toColumnMap();
        return {
          'userId': _toInt(map['user_id']),
          'fullName': map['fullname'],
          'totalSpent': _toDouble(map['total_spent']),
        };
      }).toList();

      return jsonOk({
        'days': days,
        'limit': limit,
        'items': result,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки статистики пользователей',
        details: e.toString(),
      );
    }
  }

  Future<Response> getUserAvgCheckStats(Request request, String userIdRaw) async {
    try {
      final userId = int.parse(userIdRaw);
      final days = _queryInt(request, 'days', 30);

      final rows = await database.connection.execute(
        r'''
        SELECT get_user_avg_check_period($1, $2) AS avg_check
        ''',
        parameters: [userId, days],
      );

      return jsonOk({
        'userId': userId,
        'days': days,
        'avgCheck': _toDouble(rows.first.toColumnMap()['avg_check']),
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки среднего чека пользователя',
        details: e.toString(),
      );
    }
  }

  Future<Response> getAuditLog(Request request) async {
    try {
      final limit = _queryInt(request, 'limit', 100);

      final rows = await database.connection.execute(
        r'''
        SELECT
          al.ID_AuditLog AS audit_id,
          al.ActionName AS action_name,
          al.EntityName AS entity_name,
          al.EntityID AS entity_id,
          al.OldValue AS old_value,
          al.NewValue AS new_value,
          al.ActionDate AS action_date,
          a.Email AS account_email
        FROM AuditLog al
        LEFT JOIN Accounts a ON a.ID_Account = al.Account_ID
        ORDER BY al.ActionDate DESC
        LIMIT $1
        ''',
        parameters: [limit],
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'auditId': _toInt(map['audit_id']),
          'actionName': map['action_name'],
          'entityName': map['entity_name'],
          'entityId': _toInt(map['entity_id']),
          'oldValue': map['old_value'],
          'newValue': map['new_value'],
          'actionDate': map['action_date']?.toString(),
          'accountEmail': map['account_email'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки журнала аудита',
        details: e.toString(),
      );
    }
  }
}