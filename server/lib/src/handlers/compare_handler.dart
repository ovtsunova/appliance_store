import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import '../database/database_service.dart';

class CompareHandler {
  final DatabaseService database;

  CompareHandler(this.database);

  Future<Response> compareProducts(Request request) async {
    try {
      final idsRaw = request.url.queryParameters['ids'];

      if (idsRaw == null || idsRaw.trim().isEmpty) {
        return jsonBadRequest('Не переданы идентификаторы товаров');
      }

      final ids = idsRaw
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet()
          .toList();

      if (ids.length < 2) {
        return jsonBadRequest('Для сравнения нужно минимум два товара');
      }

      final idsSql = ids.join(',');

      final productRows = await database.connection.execute(
        '''
        SELECT
          p.ID_Product AS id,
          p.ProductName AS product_name,
          p.Model AS model,
          p.Description AS description,
          p.Price AS price,
          p.StockQuantity AS stock_quantity,
          p.ImageURL AS image_url,
          p.WarrantyPeriod AS warranty_period,
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
        WHERE p.ID_Product IN ($idsSql)
        ORDER BY p.ID_Product
        ''',
      );

      final characteristicRows = await database.connection.execute(
        '''
        SELECT
          Product_ID AS product_id,
          CharacteristicName AS characteristic_name,
          CharacteristicValue AS characteristic_value
        FROM ProductCharacteristics
        WHERE Product_ID IN ($idsSql)
        ORDER BY Product_ID, ID_Characteristic
        ''',
      );

      final characteristicsByProduct = <int, List<Map<String, dynamic>>>{};

      for (final row in characteristicRows) {
        final map = row.toColumnMap();
        final productId = map['product_id'] as int;

        characteristicsByProduct.putIfAbsent(productId, () => []);
        characteristicsByProduct[productId]!.add({
          'name': map['characteristic_name'],
          'value': map['characteristic_value'],
        });
      }

      final result = productRows.map((row) {
        final map = row.toColumnMap();
        final productId = map['id'] as int;

        return {
          'id': map['id'],
          'name': map['product_name'],
          'model': map['model'],
          'description': map['description'],
          'price': map['price'],
          'stockQuantity': map['stock_quantity'],
          'imageUrl': map['image_url'],
          'warrantyPeriod': map['warranty_period'],
          'averageRating': null,
          'brand': {
            'id': map['brand_id'],
            'name': map['brand_name'],
            'countryOfOrigin': map['brand_country_of_origin'],
            'contactInfo': map['brand_contact_info'],
          },
          'category': {
            'id': map['category_id'],
            'name': map['category_name'],
            'description': map['category_description'],
            'parentCategoryId': map['category_parent_id'],
          },
          'characteristics': characteristicsByProduct[productId] ?? [],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка сравнения товаров',
        details: e.toString(),
      );
    }
  }
}