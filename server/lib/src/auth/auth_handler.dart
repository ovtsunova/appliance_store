import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import '../common/request_body.dart';
import 'auth_middleware.dart';
import 'auth_service.dart';

class AuthHandler {
  final AuthService authService;

  AuthHandler(this.authService);

  Future<Response> register(Request request) async {
    try {
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final lastName = requireString(body, 'lastName');
      final firstName = requireString(body, 'firstName');
      final patronymic = requireString(
        body,
        'patronymic',
        allowEmpty: true,
      );
      final phoneNumber = requireString(body, 'phoneNumber');
      final email = requireString(body, 'email');
      final password = requireString(body, 'password');

      final result = await authService.register(
        email: email,
        password: password,
        lastName: lastName,
        firstName: firstName,
        patronymic: patronymic,
        phoneNumber: phoneNumber,
      );

      return jsonCreated(result);
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> login(Request request) async {
    try {
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final email = requireString(body, 'email');
      final password = requireString(body, 'password');

      final result = await authService.login(
        email: email,
        password: password,
      );

      return jsonOk(result);
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> me(Request request) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final freshUser = await authService.getCurrentUserByAccountId(user.accountId);

      if (freshUser == null) {
        return jsonNotFound('Пользователь не найден');
      }

      return jsonOk(freshUser);
    } catch (e) {
      return jsonServerError(
        'Ошибка получения данных пользователя',
        details: e.toString(),
      );
    }
  }

  Future<Response> logout(Request request) async {
    return jsonOk({'message': 'Выход выполнен'});
  }

  Future<Response> forgotPassword(Request request) async {
    try {
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final email = requireString(body, 'email');

      await authService.resetPassword(email: email);

      return jsonOk({
        'message': 'Новый пароль отправлен на электронную почту',
      });
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}