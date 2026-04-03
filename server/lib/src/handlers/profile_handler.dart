import 'package:shelf/shelf.dart';

import '../auth/auth_middleware.dart';
import '../common/json_response.dart';
import '../common/request_body.dart';
import '../database/database_service.dart';

class ProfileHandler {
  final DatabaseService database;

  ProfileHandler(this.database);

  Future<Response> getProfile(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final profileRows = await database.connection.execute(
        r'''
        SELECT
          a.ID_Account AS account_id,
          a.Email AS email,
          a.RegistrationDate AS registration_date,
          a.IsBlocked AS is_blocked,
          r.RoleName AS role_name,
          u.ID_User AS user_id,
          u.LastName AS last_name,
          u.FirstName AS first_name,
          COALESCE(u.Patronymic, '') AS patronymic,
          u.PhoneNumber AS phone_number
        FROM Accounts a
        JOIN Roles r ON r.ID_Role = a.Role_ID
        JOIN Users u ON u.Account_ID = a.ID_Account
        WHERE a.ID_Account = $1
        LIMIT 1
        ''',
        parameters: [user.accountId],
      );

      if (profileRows.isEmpty) {
        return jsonNotFound('Профиль не найден');
      }

      final addressRows = await database.connection.execute(
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

      final profileMap = profileRows.first.toColumnMap();

      final addresses = addressRows.map((row) {
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

      final patronymic = (profileMap['patronymic'] as String?)?.trim() ?? '';
      final fullName = patronymic.isEmpty
          ? '${profileMap['last_name']} ${profileMap['first_name']}'
          : '${profileMap['last_name']} ${profileMap['first_name']} $patronymic';

      return jsonOk({
        'accountId': profileMap['account_id'],
        'userId': profileMap['user_id'],
        'email': profileMap['email'],
        'role': profileMap['role_name'],
        'fullName': fullName,
        'lastName': profileMap['last_name'],
        'firstName': profileMap['first_name'],
        'patronymic': profileMap['patronymic'],
        'phoneNumber': profileMap['phone_number'],
        'registrationDate': profileMap['registration_date']?.toString(),
        'isBlocked': profileMap['is_blocked'] as bool? ?? false,
        'addresses': addresses,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки профиля',
        details: e.toString(),
      );
    }
  }

  Future<Response> updateProfile(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final email = requireString(body, 'email');
      final lastName = requireString(body, 'lastName');
      final firstName = requireString(body, 'firstName');
      final patronymic = requireString(body, 'patronymic', allowEmpty: true);
      final phoneNumber = requireString(body, 'phoneNumber');

      await database.connection.runTx((tx) async {
        final existingEmail = await tx.execute(
          r'''
          SELECT 1
          FROM Accounts
          WHERE Email = $1
            AND ID_Account <> $2
          LIMIT 1
          ''',
          parameters: [email, user.accountId],
        );

        if (existingEmail.isNotEmpty) {
          throw Exception('Этот email уже используется другим пользователем');
        }

        await tx.execute(
          r'''
          UPDATE Accounts
          SET Email = $1
          WHERE ID_Account = $2
          ''',
          parameters: [email, user.accountId],
        );

        await tx.execute(
          r'''
          UPDATE Users
          SET
            LastName = $1,
            FirstName = $2,
            Patronymic = $3,
            PhoneNumber = $4
          WHERE ID_User = $5
          ''',
          parameters: [
            lastName,
            firstName,
            patronymic.isEmpty ? null : patronymic,
            phoneNumber,
            user.userId,
          ],
        );
      });

      return jsonOk({'message': 'Профиль успешно обновлён'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}