import 'package:dotenv/dotenv.dart';

class AppEnv {
  static late final DotEnv _env;

  static void load() {
    _env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  }

  static String get dbHost => _env['DB_HOST'] ?? 'localhost';
  static int get dbPort => int.tryParse(_env['DB_PORT'] ?? '5433') ?? 5433;
  static String get dbName => _env['DB_NAME'] ?? 'ApplianceStoreDB';
  static String get dbUser => _env['DB_USER'] ?? 'postgres';
  static String get dbPassword => _env['DB_PASSWORD'] ?? '';
  static int get serverPort =>
      int.tryParse(_env['SERVER_PORT'] ?? '8080') ?? 8080;

  static String get jwtSecret =>
      _env['JWT_SECRET'] ?? 'fAm1jLbQ4HaKbayCyiXKjbxvwStgyIC6jrjx6LCwdV3a7OratyiaqMDCdYlwP4TBqaWy4xAdj0yweHdDMF9Oie';

  static String get smtpHost => _env['SMTP_HOST'] ?? '';
  static int get smtpPort => int.tryParse(_env['SMTP_PORT'] ?? '587') ?? 587;
  static String get smtpUsername => _env['SMTP_USERNAME'] ?? '';
  static String get smtpPassword => _env['SMTP_PASSWORD'] ?? '';
  static String get smtpFromEmail => _env['SMTP_FROM_EMAIL'] ?? '';
  static String get smtpFromName => _env['SMTP_FROM_NAME'] ?? 'Appliance Store';
  static bool get smtpUseSsl =>
      (_env['SMTP_USE_SSL'] ?? 'false').toLowerCase() == 'true';

  static String get pgBinDir => _env['PG_BIN_DIR'] ?? '';
  static String get backupsDir => _env['BACKUPS_DIR'] ?? 'backups';
}