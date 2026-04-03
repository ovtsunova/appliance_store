import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import '../database/database_service.dart';

class PaymentHandler {
  final DatabaseService database;

  PaymentHandler(this.database);

  Future<Response> getPaymentTypes(Request request) async {
    try {
      final rows = await database.connection.execute('''
        SELECT
          ID_PaymentType AS id,
          TypeName AS type_name,
          Description AS description
        FROM PaymentTypes
        ORDER BY ID_PaymentType
      ''');

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': map['id'],
          'typeName': map['type_name'],
          'description': map['description'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки способов оплаты',
        details: e.toString(),
      );
    }
  }
}