import 'package:flutter/cupertino.dart';
import 'package:shared_models/shared_models.dart';
import 'package:televerse/televerse.dart';

import '../../../core.dart';

class BotTelegramService implements Loadable {
  final _bot = Bot(Envs.telegramBotToken);
  bool get _isInitializable => Envs.telegramBotToken.isNotEmpty;
  @override
  Future<void> onLoad() async {
    if (!_isInitializable) return;
  }

  Future<void> initializeMenu(final BuildContext context) async {
    final l10n = context.l10n;
    await _bot.start();
  }
}
