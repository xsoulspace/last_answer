// Any .dart file inside the /web directory is compiled to javascript
// and executed in the browser.

import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:tg_la_bot/tg_la_bot.dart';

Future<void> main() async {
  unawaited(TelegramBotService().onLoad());
  // Attaches the [App] component to the <body> of the page.
  runApp(App());
}
