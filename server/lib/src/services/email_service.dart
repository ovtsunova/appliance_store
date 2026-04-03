import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../config/app_env.dart';

class EmailService {
  Future<void> sendNewPasswordEmail({
    required String toEmail,
    required String newPassword,
  }) async {
    final smtpServer = SmtpServer(
      AppEnv.smtpHost,
      port: AppEnv.smtpPort,
      username: AppEnv.smtpUsername,
      password: AppEnv.smtpPassword,
      ssl: AppEnv.smtpUseSsl,
      allowInsecure: !AppEnv.smtpUseSsl,
    );

    final message = Message()
      ..from = Address(AppEnv.smtpFromEmail, AppEnv.smtpFromName)
      ..recipients.add(toEmail)
      ..subject = 'Восстановление пароля'
      ..text = '''
Здравствуйте!

Для вашего аккаунта был сгенерирован новый пароль.

Новый пароль: $newPassword

После входа в систему рекомендуем сразу изменить его в профиле.
''';

    await send(message, smtpServer);
  }
}