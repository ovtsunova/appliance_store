import 'package:shelf/shelf.dart';

import '../auth/auth_middleware.dart';
import '../common/json_response.dart';
import '../common/request_body.dart';
import '../database/database_service.dart';

class OrderHandler {
  final DatabaseService database;

  OrderHandler(this.database);

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

  Future<Response> getOrders(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rows = await database.connection.execute(
        r'''
        SELECT
          o.ID_Order AS order_id,
          o.OrderDate AS order_date,
          o.TotalAmount AS total_amount,
          o.OrderComment AS order_comment,
          s.StatusName AS status_name,
          d.TypeName AS delivery_type,
          p.TypeName AS payment_type
        FROM Orders o
        JOIN OrderStatuses s ON s.ID_Status = o.Status_ID
        JOIN DeliveryTypes d ON d.ID_DeliveryType = o.DeliveryType_ID
        JOIN PaymentTypes p ON p.ID_PaymentType = o.PaymentType_ID
        WHERE o.User_ID = $1
        ORDER BY o.OrderDate DESC
        ''',
        parameters: [user.userId],
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': _toInt(map['order_id']),
          'orderDate': map['order_date']?.toString(),
          'totalAmount': _toDouble(map['total_amount']),
          'orderComment': map['order_comment'],
          'status': map['status_name'],
          'deliveryType': map['delivery_type'],
          'paymentType': map['payment_type'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки заказов',
        details: e.toString(),
      );
    }
  }

  Future<Response> getOrderById(Request request, String orderIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

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
          d.Cost AS delivery_cost,
          d.EstimatedDeliveryTime AS estimated_delivery_time,
          p.TypeName AS payment_type,
          a.ID_Address AS address_id,
          a.Country AS country,
          a.City AS city,
          a.Street AS street,
          a.House AS house,
          a.Apartment AS apartment,
          a.PostalCode AS postal_code
        FROM Orders o
        JOIN OrderStatuses s ON s.ID_Status = o.Status_ID
        JOIN DeliveryTypes d ON d.ID_DeliveryType = o.DeliveryType_ID
        JOIN PaymentTypes p ON p.ID_PaymentType = o.PaymentType_ID
        JOIN Addresses a ON a.ID_Address = o.Address_ID
        WHERE o.ID_Order = $1 AND o.User_ID = $2
        LIMIT 1
        ''',
        parameters: [orderId, user.userId],
      );

      if (orderRows.isEmpty) {
        return jsonNotFound('Заказ не найден');
      }

      final detailRows = await database.connection.execute(
        r'''
        SELECT
          od.ID_OrderDetail AS order_detail_id,
          od.Quantity AS quantity,
          od.Price AS price,
          pr.ID_Product AS product_id,
          pr.ProductName AS product_name,
          pr.Model AS model,
          pr.ImageURL AS image_url,
          b.BrandName AS brand_name
        FROM OrderDetails od
        JOIN Products pr ON pr.ID_Product = od.Product_ID
        JOIN Brands b ON b.ID_Brand = pr.Brand_ID
        WHERE od.Order_ID = $1
        ORDER BY od.ID_OrderDetail
        ''',
        parameters: [orderId],
      );

      final historyRows = await database.connection.execute(
        r'''
        SELECT
          osh.ID_StatusHistory AS status_history_id,
          osh.StatusChangeDate AS status_change_date,
          s.StatusName AS status_name
        FROM OrderStatusHistory osh
        JOIN OrderStatuses s ON s.ID_Status = osh.Status_ID
        WHERE osh.Order_ID = $1
        ORDER BY osh.StatusChangeDate
        ''',
        parameters: [orderId],
      );

      final orderMap = orderRows.first.toColumnMap();

      final details = detailRows.map((row) {
        final map = row.toColumnMap();
        final price = _toDouble(map['price']);
        final quantity = _toInt(map['quantity']);

        return {
          'orderDetailId': _toInt(map['order_detail_id']),
          'quantity': quantity,
          'price': price,
          'itemTotal': price * quantity,
          'product': {
            'id': _toInt(map['product_id']),
            'name': map['product_name'],
            'model': map['model'],
            'imageUrl': map['image_url'],
            'brandName': map['brand_name'],
          },
        };
      }).toList();

      final history = historyRows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': _toInt(map['status_history_id']),
          'status': map['status_name'],
          'date': map['status_change_date']?.toString(),
        };
      }).toList();

      return jsonOk({
        'id': _toInt(orderMap['order_id']),
        'orderDate': orderMap['order_date']?.toString(),
        'totalAmount': _toDouble(orderMap['total_amount']),
        'orderComment': orderMap['order_comment'],
        'status': orderMap['status_name'],
        'delivery': {
          'type': orderMap['delivery_type'],
          'cost': _toDouble(orderMap['delivery_cost']),
          'estimatedTime': orderMap['estimated_delivery_time'],
        },
        'paymentType': orderMap['payment_type'],
        'address': {
          'id': _toInt(orderMap['address_id']),
          'country': orderMap['country'],
          'city': orderMap['city'],
          'street': orderMap['street'],
          'house': orderMap['house'],
          'apartment': orderMap['apartment'],
          'postalCode': orderMap['postal_code'],
        },
        'items': details,
        'history': history,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки заказа',
        details: e.toString(),
      );
    }
  }

  Future<Response> createOrder(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final addressId = requireInt(body, 'addressId', min: 1);
      final deliveryTypeId = requireInt(body, 'deliveryTypeId', min: 1);
      final paymentTypeId = requireInt(body, 'paymentTypeId', min: 1);
      final orderComment = (body['orderComment'] as String?)?.trim();

      int createdOrderId = 0;

      await database.connection.runTx((tx) async {
        final addressRows = await tx.execute(
          r'''
          SELECT 1
          FROM Addresses
          WHERE ID_Address = $1 AND User_ID = $2
          LIMIT 1
          ''',
          parameters: [addressId, user.userId],
        );

        if (addressRows.isEmpty) {
          throw Exception('Адрес доставки не найден');
        }

        final cartRows = await tx.execute(
          r'''
          SELECT
            ci.ID_CartItem AS cart_item_id,
            ci.Quantity AS quantity,
            p.ID_Product AS product_id,
            p.Price AS price,
            p.StockQuantity AS stock_quantity
          FROM CartItems ci
          JOIN Products p ON p.ID_Product = ci.Product_ID
          WHERE ci.User_ID = $1
          ORDER BY ci.ID_CartItem
          ''',
          parameters: [user.userId],
        );

        if (cartRows.isEmpty) {
          throw Exception('Корзина пуста');
        }

        double totalAmount = 0;
        final cartItems = <Map<String, dynamic>>[];

        for (final row in cartRows) {
          final map = row.toColumnMap();
          final quantity = _toInt(map['quantity']);
          final stockQuantity = _toInt(map['stock_quantity']);
          final price = _toDouble(map['price']);

          if (quantity > stockQuantity) {
            throw Exception(
              'Недостаточно товара на складе для позиции ${map['product_id']}',
            );
          }

          totalAmount += price * quantity;
          cartItems.add(map);
        }

        final statusRows = await tx.execute(
          '''
          SELECT ID_Status
          FROM OrderStatuses
          WHERE StatusName = 'Новый'
          LIMIT 1
          ''',
        );

        if (statusRows.isEmpty) {
          throw Exception('Статус "Новый" не найден');
        }

        final newStatusId = _toInt(statusRows.first[0]);

        final orderInsertRows = await tx.execute(
          r'''
          INSERT INTO Orders (
            TotalAmount,
            OrderComment,
            User_ID,
            Address_ID,
            DeliveryType_ID,
            PaymentType_ID,
            Status_ID
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7)
          RETURNING ID_Order
          ''',
          parameters: [
            totalAmount,
            orderComment?.isEmpty == true ? null : orderComment,
            user.userId,
            addressId,
            deliveryTypeId,
            paymentTypeId,
            newStatusId,
          ],
        );

        createdOrderId = _toInt(orderInsertRows.first[0]);

        for (final item in cartItems) {
          await tx.execute(
            r'''
            INSERT INTO OrderDetails (
              Quantity,
              Price,
              Order_ID,
              Product_ID
            )
            VALUES ($1, $2, $3, $4)
            ''',
            parameters: [
              _toInt(item['quantity']),
              _toDouble(item['price']),
              createdOrderId,
              _toInt(item['product_id']),
            ],
          );
        }

        await tx.execute(
          r'''
          INSERT INTO OrderStatusHistory (
            Order_ID,
            Status_ID,
            Account_ID
          )
          VALUES ($1, $2, $3)
          ''',
          parameters: [createdOrderId, newStatusId, user.accountId],
        );

        await tx.execute(
          r'''
          DELETE FROM CartItems
          WHERE User_ID = $1
          ''',
          parameters: [user.userId],
        );
      });

      return jsonCreated({
        'message': 'Заказ успешно оформлен',
        'orderId': createdOrderId,
      });
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> cancelOrder(Request request, String orderIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final orderId = int.parse(orderIdRaw);

      await database.connection.runTx((tx) async {
        final orderRows = await tx.execute(
          r'''
          SELECT
            o.ID_Order AS order_id,
            s.StatusName AS status_name
          FROM Orders o
          JOIN OrderStatuses s ON s.ID_Status = o.Status_ID
          WHERE o.ID_Order = $1 AND o.User_ID = $2
          LIMIT 1
          ''',
          parameters: [orderId, user.userId],
        );

        if (orderRows.isEmpty) {
          throw Exception('Заказ не найден');
        }

        final orderMap = orderRows.first.toColumnMap();
        final currentStatus = orderMap['status_name'] as String;

        if (currentStatus != 'Новый') {
          throw Exception('Можно отменить только новый заказ');
        }

        final cancelStatusRows = await tx.execute(
          '''
          SELECT ID_Status
          FROM OrderStatuses
          WHERE StatusName = 'Отменён'
          LIMIT 1
          ''',
        );

        if (cancelStatusRows.isEmpty) {
          throw Exception('Статус "Отменён" не найден');
        }

        final cancelStatusId = _toInt(cancelStatusRows.first[0]);

        await tx.execute(
          r'''
          UPDATE Orders
          SET Status_ID = $1
          WHERE ID_Order = $2
          ''',
          parameters: [cancelStatusId, orderId],
        );

        await tx.execute(
          r'''
          INSERT INTO OrderStatusHistory (
            Order_ID,
            Status_ID,
            Account_ID
          )
          VALUES ($1, $2, $3)
          ''',
          parameters: [orderId, cancelStatusId, user.accountId],
        );
      });

      return jsonOk({'message': 'Заказ отменён'});
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}