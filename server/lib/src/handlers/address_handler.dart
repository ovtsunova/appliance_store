import 'package:shelf/shelf.dart';

import '../auth/auth_middleware.dart';
import '../common/json_response.dart';
import '../common/request_body.dart';
import '../database/database_service.dart';

class AddressHandler {
  final DatabaseService database;

  AddressHandler(this.database);

  Future<Response> getAddresses(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rows = await database.connection.execute(
        r'''
        SELECT
          ID_Address AS id,
          Country AS country,
          City AS city,
          Street AS street,
          House AS house,
          Apartment AS apartment,
          PostalCode AS postal_code
        FROM Addresses
        WHERE User_ID = $1
        ORDER BY ID_Address
        ''',
        parameters: [user.userId],
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        return {
          'id': map['id'],
          'country': map['country'],
          'city': map['city'],
          'street': map['street'],
          'house': map['house'],
          'apartment': map['apartment'],
          'postalCode': map['postal_code'],
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки адресов',
        details: e.toString(),
      );
    }
  }

  Future<Response> createAddress(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final country = requireString(body, 'country');
      final city = requireString(body, 'city');
      final street = requireString(body, 'street');
      final house = requireString(body, 'house');
      final apartment = requireString(body, 'apartment', allowEmpty: true);
      final postalCode = requireString(body, 'postalCode');

      final rows = await database.connection.execute(
        r'''
        INSERT INTO Addresses (
          Country,
          City,
          Street,
          House,
          Apartment,
          PostalCode,
          User_ID
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING ID_Address
        ''',
        parameters: [
          country,
          city,
          street,
          house,
          apartment.isEmpty ? null : apartment,
          postalCode,
          user.userId,
        ],
      );

      return jsonCreated({
        'message': 'Адрес успешно добавлен',
        'addressId': rows.first[0],
      });
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось добавить адрес',
        details: e.toString(),
      );
    }
  }

  Future<Response> updateAddress(Request request, String addressIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final addressId = int.parse(addressIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final country = requireString(body, 'country');
      final city = requireString(body, 'city');
      final street = requireString(body, 'street');
      final house = requireString(body, 'house');
      final apartment = requireString(body, 'apartment', allowEmpty: true);
      final postalCode = requireString(body, 'postalCode');

      final result = await database.connection.execute(
        r'''
        UPDATE Addresses
        SET
          Country = $1,
          City = $2,
          Street = $3,
          House = $4,
          Apartment = $5,
          PostalCode = $6
        WHERE ID_Address = $7 AND User_ID = $8
        ''',
        parameters: [
          country,
          city,
          street,
          house,
          apartment.isEmpty ? null : apartment,
          postalCode,
          addressId,
          user.userId,
        ],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Адрес не найден');
      }

      return jsonOk({'message': 'Адрес успешно обновлён'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        'Не удалось обновить адрес',
        details: e.toString(),
      );
    }
  }

  Future<Response> deleteAddress(Request request, String addressIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final addressId = int.parse(addressIdRaw);

      final result = await database.connection.execute(
        r'''
        DELETE FROM Addresses
        WHERE ID_Address = $1 AND User_ID = $2
        ''',
        parameters: [addressId, user.userId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Адрес не найден');
      }

      return jsonOk({'message': 'Адрес удалён'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось удалить адрес',
        details: e.toString(),
      );
    }
  }
}