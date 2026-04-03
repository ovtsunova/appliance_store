import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../common/json_response.dart';
import '../database/database_service.dart';
import '../config/app_env.dart';

class SystemHandler {
  final DatabaseService database;

  const SystemHandler(this.database);

  String _pgExecutable(String baseName) {
    final executable = Platform.isWindows ? '$baseName.exe' : baseName;

    if (AppEnv.pgBinDir.trim().isEmpty) {
      return executable;
    }

    return '${AppEnv.pgBinDir}${Platform.pathSeparator}$executable';
  }

  String _csvEscape(dynamic value) {
    final text = value?.toString() ?? '';
    final escaped = text.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<Response> exportOrdersCsv(Request request) async {
    try {
      final rows = await database.connection.execute(
        '''
        SELECT
          "Код заказа" AS id,
          "Дата заказа" AS order_date,
          "Покупатель" AS customer,
          "Статус" AS status,
          "Способ доставки" AS delivery_type,
          "Способ оплаты" AS payment_type,
          "Адрес доставки" AS delivery_address,
          "Итоговая сумма" AS total_amount
        FROM OrdersView
        ORDER BY "Дата заказа" DESC
        ''',
      );

      final buffer = StringBuffer();
      buffer.writeln([
        _csvEscape('Код заказа'),
        _csvEscape('Дата заказа'),
        _csvEscape('Покупатель'),
        _csvEscape('Статус'),
        _csvEscape('Способ доставки'),
        _csvEscape('Способ оплаты'),
        _csvEscape('Адрес доставки'),
        _csvEscape('Итоговая сумма'),
      ].join(','));

      for (final row in rows) {
        final map = row.toColumnMap();
        buffer.writeln([
          _csvEscape(map['id']),
          _csvEscape(map['order_date']),
          _csvEscape(map['customer']),
          _csvEscape(map['status']),
          _csvEscape(map['delivery_type']),
          _csvEscape(map['payment_type']),
          _csvEscape(map['delivery_address']),
          _csvEscape(map['total_amount']),
        ].join(','));
      }

      return Response.ok(
        buffer.toString(),
        headers: {
          'content-type': 'text/csv; charset=utf-8',
          'content-disposition':
              'attachment; filename="orders_export_${DateTime.now().millisecondsSinceEpoch}.csv"',
        },
      );
    } catch (e) {
      return jsonServerError(
        'Ошибка экспорта CSV',
        details: e.toString(),
      );
    }
  }

  Future<Response> createBackup(Request request) async {
    try {
      final backupDir = Directory(AppEnv.backupsDir);
      if (!backupDir.existsSync()) {
        backupDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final fileName = 'backup_$timestamp.sql';
      final filePath =
          '${backupDir.path}${Platform.pathSeparator}$fileName';

      final result = await Process.run(
        _pgExecutable('pg_dump'),
        [
          '-h',
          AppEnv.dbHost,
          '-p',
          AppEnv.dbPort.toString(),
          '-U',
          AppEnv.dbUser,
          '-d',
          AppEnv.dbName,
          '--clean',
          '--if-exists',
          '--no-owner',
          '--no-privileges',
          '-f',
          filePath,
        ],
        environment: {
          ...Platform.environment,
          'PGPASSWORD': AppEnv.dbPassword,
        },
      );

      if (result.exitCode != 0) {
        return jsonServerError(
          'Ошибка создания резервной копии',
          details: result.stderr.toString(),
        );
      }

      return jsonOk({
        'message': 'Резервная копия успешно создана',
        'fileName': fileName,
        'filePath': filePath,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка создания резервной копии',
        details: e.toString(),
      );
    }
  }

  Future<Response> listBackups(Request request) async {
    try {
      final backupDir = Directory(AppEnv.backupsDir);
      if (!backupDir.existsSync()) {
        return jsonOk([]);
      }

      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.sql'))
          .toList()
        ..sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
        );

      final result = files.map((file) {
        final stat = file.statSync();
        return {
          'fileName': file.uri.pathSegments.last,
          'filePath': file.path,
          'modifiedAt': stat.modified.toIso8601String(),
          'sizeBytes': stat.size,
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка получения списка резервных копий',
        details: e.toString(),
      );
    }
  }

  Future<Response> restoreBackup(Request request) async {
    try {
      final rawBody = await request.readAsString();
      String? filePath;

      if (rawBody.trim().isNotEmpty) {
        final body = jsonDecode(rawBody) as Map<String, dynamic>;
        filePath = body['filePath']?.toString();
      }

      if (filePath == null || filePath.trim().isEmpty) {
        final backupDir = Directory(AppEnv.backupsDir);
        if (!backupDir.existsSync()) {
          return jsonBadRequest('Папка с резервными копиями не найдена');
        }

        final files = backupDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.sql'))
            .toList()
          ..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

        if (files.isEmpty) {
          return jsonBadRequest('Нет резервных копий для восстановления');
        }

        filePath = files.first.path;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        return jsonBadRequest('Файл резервной копии не найден');
      }

      final result = await Process.run(
        _pgExecutable('psql'),
        [
          '-h',
          AppEnv.dbHost,
          '-p',
          AppEnv.dbPort.toString(),
          '-U',
          AppEnv.dbUser,
          '-d',
          AppEnv.dbName,
          '-f',
          filePath,
        ],
        environment: {
          ...Platform.environment,
          'PGPASSWORD': AppEnv.dbPassword,
        },
      );

      if (result.exitCode != 0) {
        return jsonServerError(
          'Ошибка восстановления базы данных',
          details: result.stderr.toString(),
        );
      }

      return jsonOk({
        'message': 'База данных успешно восстановлена',
        'filePath': filePath,
      });
    } catch (e) {
      return jsonServerError(
        'Ошибка восстановления резервной копии',
        details: e.toString(),
      );
    }
  }
}