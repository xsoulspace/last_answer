import 'package:televerse/televerse.dart';

import '../envs.dart';

class TelegramBotService {
  Bot? _bot;
  bool get _isInitializable => Envs.telegramBotToken.isNotEmpty;
  Future<void> onLoad() async {
    if (!_isInitializable) return;
    final bot = _bot = Bot(Envs.telegramBotToken);

    await bot.start();

    /// Sets up the /settings command listener
    bot
      ..settings((ctx) async => ctx.reply('Settings'))
      /// Sets up the /help command listener
      ..help((ctx) async => ctx.reply('Help'))
      /// The [bot.hears] method allows you to listen to messages that match a regular expression.
      /// You can use the `Context.matches` getter to access the matches of the regular expression.
      ..hears(RegExp('Hello, (.*)!'), (ctx) async {
        await ctx.reply('${ctx.matches[1]} must be a doing great!');
      });
    print('Starting telegram bot...');
    // await bot.start(
    //   (ctx) {
    //     // `TODO`(arenukvern): add language dependency,
    //     print('tada');
    //     ctx.reply(
    //       // ignore: lines_longer_than_80_chars
    //       '👋, ${ctx.from?.username ?? ''}. Нажми кнопку ниже, чтобы открыть приложение.',
    //       replyMarkup: ReplyKeyboardMarkup(
    //         keyboard: [
    //           [
    //             const KeyboardButton(
    //               text: 'Открыть',
    //               webApp: WebAppInfo(url: Envs.telegramWebAppUrl),
    //             ),
    //           ]
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  void dispose() {
    print('Stopping telegram bot...');
    _bot?.stop();
  }
}
