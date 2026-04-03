import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/register_request.dart';

class AuthRepository {
  final Dio dio;
  final SessionStorage storage;

  AuthRepository({
    required this.dio,
    required this.storage,
  });

  Future<AuthSession> login(LoginRequest request) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final session = AuthSession.fromJson(
        response.data as Map<String, dynamic>,
      );

      await storage.saveSession(session);
      return session;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<AuthSession> register(RegisterRequest request) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final session = AuthSession.fromJson(
        response.data as Map<String, dynamic>,
      );

      await storage.saveSession(session);
      return session;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await dio.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email.trim(),
        },
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<AuthSession?> restoreSession() {
    return storage.getSession();
  }

  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } catch (_) {
      // даже если сервер не ответил, локальную сессию всё равно очищаем
    } finally {
      await storage.clear();
    }
  }

  ApiException _mapException(DioException e) {
    final err = e.error;
    if (err is ApiException) {
      return err;
    }

    return ApiException('Не удалось выполнить запрос к серверу');
  }
}