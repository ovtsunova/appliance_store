import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../config/app_env.dart';
import '../database/database_service.dart';
import '../services/email_service.dart';
import 'user_context.dart';

class AuthService {
  final DatabaseService database;
  final EmailService emailService;

  AuthService(this.database, this.emailService);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String lastName,
    required String firstName,
    required String patronymic,
    required String phoneNumber,
  }) async {
    final existing = await database.connection.execute(
      r'''
      SELECT 1
      FROM Accounts
      WHERE Email = $1
      LIMIT 1
      ''',
      parameters: [email],
    );

    if (existing.isNotEmpty) {
      throw Exception('Пользователь с таким email уже существует');
    }

    final roleRows = await database.connection.execute(
      '''
      SELECT ID_Role
      FROM Roles
      WHERE RoleName = 'Покупатель'
      LIMIT 1
      ''',
    );

    if (roleRows.isEmpty) {
      throw Exception('Роль "Покупатель" не найдена');
    }

    final roleId = roleRows.first[0] as int;

    final hashRows = await database.connection.execute(
      r'''
      SELECT crypt($1, gen_salt('bf')) AS password_hash
      ''',
      parameters: [password],
    );

    final passwordHash = hashRows.first[0] as String;

    await database.connection.execute(
      r'''
      CALL RegisterUser($1, $2, $3, $4, $5, $6, $7)
      ''',
      parameters: [
        email,
        passwordHash,
        roleId,
        lastName,
        firstName,
        patronymic,
        phoneNumber,
      ],
    );

    final user = await _findUserByEmail(email);

    if (user == null) {
      throw Exception('Не удалось получить данные зарегистрированного пользователя');
    }

    final token = _generateToken(user);

    return {
      'token': token,
      'user': user,
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final rows = await database.connection.execute(
      r'''
      SELECT
        a.ID_Account AS account_id,
        a.Email AS email,
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
      WHERE a.Email = $1
        AND a.PasswordHash = crypt($2, a.PasswordHash)
      LIMIT 1
      ''',
      parameters: [email, password],
    );

    if (rows.isEmpty) {
      throw Exception('Неверный email или пароль');
    }

    final map = rows.first.toColumnMap();

    final isBlocked = map['is_blocked'] as bool? ?? false;
    if (isBlocked) {
      throw Exception('Аккаунт заблокирован');
    }

    final user = _mapUser(map);
    final token = _generateToken(user);

    return {
      'token': token,
      'user': user,
    };
  }

  Future<Map<String, dynamic>?> getCurrentUserByAccountId(int accountId) async {
    final rows = await database.connection.execute(
      r'''
      SELECT
        a.ID_Account AS account_id,
        a.Email AS email,
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
      parameters: [accountId],
    );

    if (rows.isEmpty) {
      return null;
    }

    final map = rows.first.toColumnMap();

    final isBlocked = map['is_blocked'] as bool? ?? false;
    if (isBlocked) {
      throw Exception('Аккаунт заблокирован');
    }

    return _mapUser(map);
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    final user = await _findUserByEmail(email);

    if (user == null) {
      throw Exception('Пользователь с таким email не найден');
    }

    final newPassword = _generateRandomPassword();

    final hashRows = await database.connection.execute(
      r'''
      SELECT crypt($1, gen_salt('bf')) AS password_hash
      ''',
      parameters: [newPassword],
    );

    final passwordHash = hashRows.first[0] as String;

    await database.connection.execute(
      r'''
      UPDATE Accounts
      SET PasswordHash = $1
      WHERE Email = $2
      ''',
      parameters: [passwordHash, email],
    );

    await emailService.sendNewPasswordEmail(
      toEmail: email,
      newPassword: newPassword,
    );
  }

  UserContext verifyToken(String token) {
    final jwt = JWT.verify(token, SecretKey(AppEnv.jwtSecret));
    final payload = jwt.payload as Map<String, dynamic>;
    return UserContext.fromMap(payload);
  }

  String _generateToken(Map<String, dynamic> user) {
    final jwt = JWT({
      'accountId': user['accountId'],
      'userId': user['userId'],
      'email': user['email'],
      'role': user['role'],
      'fullName': user['fullName'],
    });

    return jwt.sign(
      SecretKey(AppEnv.jwtSecret),
      expiresIn: const Duration(days: 7),
    );
  }

  Future<Map<String, dynamic>?> _findUserByEmail(String email) async {
    final rows = await database.connection.execute(
      r'''
      SELECT
        a.ID_Account AS account_id,
        a.Email AS email,
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
      WHERE a.Email = $1
      LIMIT 1
      ''',
      parameters: [email],
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapUser(rows.first.toColumnMap());
  }

  Map<String, dynamic> _mapUser(Map<String, dynamic> map) {
    final patronymic = (map['patronymic'] as String?)?.trim() ?? '';

    final fullName = patronymic.isEmpty
        ? '${map['last_name']} ${map['first_name']}'
        : '${map['last_name']} ${map['first_name']} $patronymic';

    return {
      'accountId': map['account_id'],
      'userId': map['user_id'],
      'email': map['email'],
      'role': map['role_name'],
      'fullName': fullName,
      'phoneNumber': map['phone_number'],
      'isBlocked': map['is_blocked'] as bool? ?? false,
    };
  }

  String _generateRandomPassword([int length = 10]) {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}