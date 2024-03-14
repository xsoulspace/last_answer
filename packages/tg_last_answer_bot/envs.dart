import 'dart:io';

class Envs {
  static const String telegramWebAppUrl = 'https://xsoulspace.dev/last_answer';
  static final telegramBotToken =
      Platform.environment['TELEGRAM_BOT_TOKEN'] ?? '';
}
