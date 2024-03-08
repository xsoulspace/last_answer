import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

import '../envs.dart';

class TelegramBotService {
  final _bot = Bot(Envs.telegramBotToken);
  bool get _isInitializable => Envs.telegramBotToken.isNotEmpty;
  Future<void> onLoad() async {
    if (!_isInitializable) return;
    await _bot.start();
    await _initializeMenu();
  }

  Future<void> _initializeMenu() async {
    await _bot.command('start', (final ctx) {
      ctx.reply(
        '👋, ${ctx.from?.username ?? ''}. Нажми кнопку ниже, чтобы открыть приложение.',
        replyMarkup: ReplyKeyboardMarkup(
          keyboard: [
            [
              const KeyboardButton(
                text: 'Открыть',
                webApp: WebAppInfo(url: Envs.webAppUrl),
              ),
            ]
          ],
        ),
      );
    });
  }
}
