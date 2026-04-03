import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import 'auth_service.dart';
import 'user_context.dart';

Middleware requireAuth(AuthService authService) {
  return (innerHandler) {
    return (request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.toLowerCase().startsWith('bearer ')) {
        return jsonUnauthorized('Требуется авторизация');
      }

      final token = authHeader.substring(7).trim();

      if (token.isEmpty) {
        return jsonUnauthorized('Токен не передан');
      }

      try {
        final user = authService.verifyToken(token);

        final updatedRequest = request.change(
          context: {
            ...request.context,
            userContextKey: user,
          },
        );

        return innerHandler(updatedRequest);
      } catch (_) {
        return jsonUnauthorized('Недействительный или просроченный токен');
      }
    };
  };
}

Middleware requireRole(Iterable<String> allowedRoles) {
  final allowed = allowedRoles.toSet();

  return (innerHandler) {
    return (request) async {
      final user = request.context[userContextKey];

      if (user is! UserContext) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      if (!allowed.contains(user.role)) {
        return jsonForbidden('Недостаточно прав для выполнения операции');
      }

      return innerHandler(request);
    };
  };
}

UserContext? currentUser(Request request) {
  final user = request.context[userContextKey];
  if (user is UserContext) {
    return user;
  }
  return null;
}