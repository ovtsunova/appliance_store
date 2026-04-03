import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../database/database_service.dart';

class ProductHandler {
  final DatabaseService database;

  ProductHandler(this.database);

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

  Future<Response> getProducts(Request request) async {
    try {
      final productRows = await database.connection.execute('''
        SELECT
          p.ID_Product AS id,
          p.ProductName AS product_name,
          p.Model AS model,
          p.Description AS description,
          p.Price AS price,
          p.StockQuantity AS stock_quantity,
          p.ImageURL AS image_url,
          p.WarrantyPeriod AS warranty_period,
          avg_reviews.average_rating AS average_rating,
          b.ID_Brand AS brand_id,
          b.BrandName AS brand_name,
          b.CountryOfOrigin AS brand_country_of_origin,
          b.ContactInfo AS brand_contact_info,
          c.ID_Category AS category_id,
          c.CategoryName AS category_name,
          c.CategoryDescription AS category_description,
          c.ParentCategory_ID AS category_parent_id
        FROM Products p
        JOIN Brands b ON b.ID_Brand = p.Brand_ID
        JOIN Categories c ON c.ID_Category = p.Category_ID
        LEFT JOIN (
          SELECT
            Product_ID,
            AVG(Rating) AS average_rating
          FROM Reviews
          GROUP BY Product_ID
        ) avg_reviews ON avg_reviews.Product_ID = p.ID_Product
        ORDER BY p.ID_Product
      ''');

      final characteristicRows = await database.connection.execute('''
        SELECT
          Product_ID AS product_id,
          CharacteristicName AS characteristic_name,
          CharacteristicValue AS characteristic_value
        FROM ProductCharacteristics
        ORDER BY Product_ID, ID_Characteristic
      ''');

      final characteristicsByProduct = <int, List<Map<String, dynamic>>>{};

      for (final row in characteristicRows) {
        final map = row.toColumnMap();
        final productId = _toInt(map['product_id']);

        characteristicsByProduct.putIfAbsent(productId, () => []);
        characteristicsByProduct[productId]!.add({
          'name': map['characteristic_name'],
          'value': map['characteristic_value'],
        });
      }

      final result = productRows.map((row) {
        final map = row.toColumnMap();
        final productId = _toInt(map['id']);

        return {
          'id': productId,
          'name': map['product_name'],
          'model': map['model'],
          'description': map['description'],
          'price': _toDouble(map['price']),
          'stockQuantity': _toInt(map['stock_quantity']),
          'imageUrl': map['image_url'],
          'warrantyPeriod': map['warranty_period'],
          'averageRating': map['average_rating'] == null
              ? null
              : _toDouble(map['average_rating']),
          'brand': {
            'id': _toInt(map['brand_id']),
            'name': map['brand_name'],
            'countryOfOrigin': map['brand_country_of_origin'],
            'contactInfo': map['brand_contact_info'],
          },
          'category': {
            'id': _toInt(map['category_id']),
            'name': map['category_name'],
            'description': map['category_description'],
            'parentCategoryId': map['category_parent_id'],
          },
          'characteristics': characteristicsByProduct[productId] ?? [],
        };
      }).toList();

      return Response.ok(
        jsonEncode(result),
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'message': 'Ошибка загрузки товаров',
          'details': e.toString(),
        }),
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
      );
    }
  }

  Future<Response> getProductById(Request request, String id) async {
    try {
      final productId = int.parse(id);

      final productRows = await database.connection.execute(
        r'''
        SELECT
          p.ID_Product AS id,
          p.ProductName AS product_name,
          p.Model AS model,
          p.Description AS description,
          p.Price AS price,
          p.StockQuantity AS stock_quantity,
          p.ImageURL AS image_url,
          p.WarrantyPeriod AS warranty_period,
          avg_reviews.average_rating AS average_rating,
          b.ID_Brand AS brand_id,
          b.BrandName AS brand_name,
          b.CountryOfOrigin AS brand_country_of_origin,
          b.ContactInfo AS brand_contact_info,
          c.ID_Category AS category_id,
          c.CategoryName AS category_name,
          c.CategoryDescription AS category_description,
          c.ParentCategory_ID AS category_parent_id
        FROM Products p
        JOIN Brands b ON b.ID_Brand = p.Brand_ID
        JOIN Categories c ON c.ID_Category = p.Category_ID
        LEFT JOIN (
          SELECT
            Product_ID,
            AVG(Rating) AS average_rating
          FROM Reviews
          GROUP BY Product_ID
        ) avg_reviews ON avg_reviews.Product_ID = p.ID_Product
        WHERE p.ID_Product = $1
        ''',
        parameters: [productId],
      );

      if (productRows.isEmpty) {
        return Response.notFound(
          jsonEncode({'message': 'Товар не найден'}),
          headers: {
            'content-type': 'application/json; charset=utf-8',
          },
        );
      }

      final characteristicRows = await database.connection.execute(
        r'''
        SELECT
          CharacteristicName AS characteristic_name,
          CharacteristicValue AS characteristic_value
        FROM ProductCharacteristics
        WHERE Product_ID = $1
        ORDER BY ID_Characteristic
        ''',
        parameters: [productId],
      );

      final productMap = productRows.first.toColumnMap();

      final characteristics = characteristicRows.map((row) {
        final map = row.toColumnMap();
        return {
          'name': map['characteristic_name'],
          'value': map['characteristic_value'],
        };
      }).toList();

      final result = {
        'id': _toInt(productMap['id']),
        'name': productMap['product_name'],
        'model': productMap['model'],
        'description': productMap['description'],
        'price': _toDouble(productMap['price']),
        'stockQuantity': _toInt(productMap['stock_quantity']),
        'imageUrl': productMap['image_url'],
        'warrantyPeriod': productMap['warranty_period'],
        'averageRating': productMap['average_rating'] == null
            ? null
            : _toDouble(productMap['average_rating']),
        'brand': {
          'id': _toInt(productMap['brand_id']),
          'name': productMap['brand_name'],
          'countryOfOrigin': productMap['brand_country_of_origin'],
          'contactInfo': productMap['brand_contact_info'],
        },
        'category': {
          'id': _toInt(productMap['category_id']),
          'name': productMap['category_name'],
          'description': productMap['category_description'],
          'parentCategoryId': productMap['category_parent_id'],
        },
        'characteristics': characteristics,
      };

      return Response.ok(
        jsonEncode(result),
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'message': 'Ошибка загрузки товара',
          'details': e.toString(),
        }),
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
      );
    }
  }
}