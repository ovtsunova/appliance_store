import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import '../database/database_service.dart';

class BrandHandler {
  final DatabaseService database;

  BrandHandler(this.database);

  Future<Response> getBrands(Request request) async {
    try {
      final rows = await database.connection.execute('''
        SELECT
          ID_Brand AS id,
          BrandName AS name,
          CountryOfOrigin AS country_of_origin,
          ContactInfo AS contact_info
        FROM Brands
        ORDER BY BrandName
      ''');

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': map['id'],
          'name': map['name'],
          'countryOfOrigin': map['country_of_origin'],
          'contactInfo': map['contact_info'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки брендов',
        details: e.toString(),
      );
    }
  }
}