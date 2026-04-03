import 'package:postgres/postgres.dart';

import '../config/app_env.dart';

class DatabaseService {
  late final Connection _connection;

  Connection get connection => _connection;

  Future<void> open() async {
    _connection = await Connection.open(
      Endpoint(
        host: AppEnv.dbHost,
        port: AppEnv.dbPort,
        database: AppEnv.dbName,
        username: AppEnv.dbUser,
        password: AppEnv.dbPassword,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
  }

  Future<void> close() async {
    await _connection.close();
  }
}