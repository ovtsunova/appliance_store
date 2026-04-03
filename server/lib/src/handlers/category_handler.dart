import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import '../database/database_service.dart';

class CategoryHandler {
  final DatabaseService database;

  CategoryHandler(this.database);

  Future<Response> getCategories(Request request) async {
    try {
      final rows = await database.connection.execute('''
        SELECT
          ID_Category AS id,
          CategoryName AS name,
          CategoryDescription AS description,
          ParentCategory_ID AS parent_category_id
        FROM Categories
        ORDER BY CategoryName
      ''');

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': map['id'],
          'name': map['name'],
          'description': map['description'],
          'parentCategoryId': map['parent_category_id'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки категорий',
        details: e.toString(),
      );
    }
  }
}