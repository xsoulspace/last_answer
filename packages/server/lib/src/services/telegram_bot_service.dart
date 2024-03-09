import 'package:server/envs.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

class TelegramBotService {
  late final _bot = Bot(Envs.telegramBotToken);
  bool get _isInitializable => Envs.telegramBotToken.isNotEmpty;
  Future<void> onLoad() async {
    if (!_isInitializable) return;
    await _bot.start();
    await _initializeMenu();
  }

  Future<void> _initializeMenu() async {
    await _bot.command('start', (final ctx) {
      // TODO(arenukvern): add language dependency,
      ctx.reply(
        // ignore: lines_longer_than_80_chars
        '👋, ${ctx.from?.username ?? ''}. Нажми кнопку ниже, чтобы открыть приложение.',
        replyMarkup: ReplyKeyboardMarkup(
          keyboard: [
            [
              const KeyboardButton(
                text: 'Открыть',
                webApp: WebAppInfo(url: Envs.telegramWebAppUrl),
              ),
            ]
          ],
        ),
      );
    });
  }
}
