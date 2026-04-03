import 'package:shelf/shelf.dart';

import '../auth/auth_middleware.dart';
import '../common/json_response.dart';
import '../database/database_service.dart';

class FavoritesHandler {
  final DatabaseService database;

  FavoritesHandler(this.database);

  Future<Response> getFavorites(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rows = await database.connection.execute(
        r'''
        SELECT
          f.ID_Favorite AS favorite_id,
          f.AddedDate AS added_date,
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
          b.CountryOfOrigin AS brand_country_of_origin,
          b.ContactInfo AS brand_contact_info,
          c.ID_Category AS category_id,
          c.CategoryName AS category_name,
          c.CategoryDescription AS category_description,
          c.ParentCategory_ID AS category_parent_id
        FROM Favorites f
        JOIN Products p ON p.ID_Product = f.Product_ID
        JOIN Brands b ON b.ID_Brand = p.Brand_ID
        JOIN Categories c ON c.ID_Category = p.Category_ID
        WHERE f.User_ID = $1
        ORDER BY f.AddedDate DESC
        ''',
        parameters: [user.userId],
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'favoriteId': map['favorite_id'],
          'addedDate': map['added_date']?.toString(),
          'product': {
            'id': map['product_id'],
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
            'characteristics': [],
          },
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки избранного',
        details: e.toString(),
      );
    }
  }

  Future<Response> addFavorite(Request request, String productIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final productId = int.parse(productIdRaw);

      final productRows = await database.connection.execute(
        r'''
        SELECT 1
        FROM Products
        WHERE ID_Product = $1
        LIMIT 1
        ''',
        parameters: [productId],
      );

      if (productRows.isEmpty) {
        return jsonNotFound('Товар не найден');
      }

      await database.connection.execute(
        r'''
        INSERT INTO Favorites (User_ID, Product_ID)
        VALUES ($1, $2)
        ON CONFLICT (User_ID, Product_ID) DO NOTHING
        ''',
        parameters: [user.userId, productId],
      );

      return jsonCreated({'message': 'Товар добавлен в избранное'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось добавить товар в избранное',
        details: e.toString(),
      );
    }
  }

  Future<Response> removeFavorite(Request request, String productIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final productId = int.parse(productIdRaw);

      final result = await database.connection.execute(
        r'''
        DELETE FROM Favorites
        WHERE User_ID = $1 AND Product_ID = $2
        ''',
        parameters: [user.userId, productId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Товар не найден в избранном');
      }

      return jsonOk({'message': 'Товар удалён из избранного'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось удалить товар из избранного',
        details: e.toString(),
      );
    }
  }
}