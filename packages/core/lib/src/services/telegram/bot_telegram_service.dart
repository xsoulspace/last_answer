import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_models/shared_models.dart';
import 'package:televerse/televerse.dart';

import '../../../core.dart';

class BotTelegramService with ChangeNotifier implements Loadable {
  final _bot = Bot(Envs.telegramBotToken);
  bool get _isInitializable => Envs.telegramBotToken.isNotEmpty;
  @override
  Future<void> onLoad() async {
    if (!_isInitializable) return;
    await _bot.start();
  }

  Future<void> initializeMenu(final BuildContext context) async {
    final l10n = context.l10n;
  }

  @override
  void dispose() {
    unawaited(_bot.stop());
    super.dispose();
  }
}
