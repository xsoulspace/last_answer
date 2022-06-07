import 'dart:math';

import 'package:lastanswer/abstract/localization/localized_text.dart';

class Greeting {
  Greeting() : _random = Random();
  final Random _random;
  int get _randomMax => morning.values.length;
  int get _randomMin => 0;
  int _nextRandom() => _randomMin + _random.nextInt(_randomMax - _randomMin);

  static LocalizedText? _previousLocalizedGreeting;
  static String _previousStrGreeting = '';
  String get current {
    final now = DateTime.now();

    final int randomNumber = _nextRandom();
    LocalizedText text;
    if (now.hour < 7) {
      text = night;
    } else if (now.hour < 12 && now.hour >= 7) {
      text = morning;
    } else if (now.hour > 18) {
      text = evening;
    } else {
      text = day;
    }
    final newGreeting = text.values.values.toList()[randomNumber] ?? '';
    if (_previousLocalizedGreeting != text) {
      _previousLocalizedGreeting = text;

      return _previousStrGreeting = newGreeting;
    } else {
      return _previousStrGreeting;
    }
  }

  static const morning = LocalizedText(
    en: 'Good morning',
    ru: 'Доброе утро',
    it: 'Buon giorno',
    ga: 'Maidin mhaith',
  );
  static const day = LocalizedText(
    en: 'Good afternoon',
    ru: 'Добрый день',
    it: 'Buona giornata',
    ga: 'Lá maith',
  );
  static const evening = LocalizedText(
    en: 'Good evening',
    ru: 'Добрый вечер',
    it: 'Buona serata',
    ga: 'Tráthnóna maith',
  );
  static const night = LocalizedText(
    en: 'Good night',
    ru: 'Доброй ночи',
    it: 'Buona notte',
    ga: 'Oíche mhaith',
  );
}
