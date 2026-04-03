import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/session_storage.dart';
import 'api_exception.dart';

class ApiClient {
  final SessionStorage storage;

  ApiClient(this.storage);

  Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final response = error.response;
          final data = response?.data;

          String message = 'Произошла ошибка при обращении к серверу';

          if (data is Map<String, dynamic>) {
            if (data['message'] is String) {
              message = data['message'] as String;
            } else if (data['error'] is String) {
              message = data['error'] as String;
            }
          } else if (response?.statusMessage != null &&
              response!.statusMessage!.isNotEmpty) {
            message = response.statusMessage!;
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException(
                message,
                statusCode: response?.statusCode,
              ),
              response: response,
              type: error.type,
            ),
          );
        },
      ),
    );

    return dio;
  }
}