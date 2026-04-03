import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import '../database/database_service.dart';

class DeliveryHandler {
  final DatabaseService database;

  DeliveryHandler(this.database);

  Future<Response> getDeliveryTypes(Request request) async {
    try {
      final rows = await database.connection.execute('''
        SELECT
          ID_DeliveryType AS id,
          TypeName AS type_name,
          Cost AS cost,
          EstimatedDeliveryTime AS estimated_delivery_time
        FROM DeliveryTypes
        ORDER BY ID_DeliveryType
      ''');

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': map['id'],
          'typeName': map['type_name'],
          'cost': map['cost'],
          'estimatedDeliveryTime': map['estimated_delivery_time'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки способов доставки',
        details: e.toString(),
      );
    }
  }
}