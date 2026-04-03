import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/register_request.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(sessionStorageProvider);
  return ApiClient(storage).build();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.read(dioProvider),
    storage: ref.read(sessionStorageProvider),
  );
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  final AuthRepository repository;

  AuthController(this.repository) : super(const AsyncValue.data(null));

  Future<void> restoreSession() async {
    state = const AsyncValue.loading();
    try {
      final session = await repository.restoreSession();
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AuthSession> login(LoginRequest request) async {
    state = const AsyncValue.loading();
    try {
      final session = await repository.login(request);
      state = AsyncValue.data(session);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<AuthSession> register(RegisterRequest request) async {
    state = const AsyncValue.loading();
    try {
      final session = await repository.register(request);
      state = AsyncValue.data(session);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await repository.forgotPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
  final controller = AuthController(ref.read(authRepositoryProvider));
  controller.restoreSession();
  return controller;
});