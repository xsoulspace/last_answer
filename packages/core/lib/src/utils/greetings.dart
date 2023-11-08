import 'dart:math';

import '../models/models.dart';

class Greeting {
  Greeting() : _random = Random();
  final Random _random;
  int get _randomMax => morning.values.length;
  int get _randomMin => 0;
  int _nextRandom() => _randomMin + _random.nextInt(_randomMax - _randomMin);

  static LocalizedTextModel? _previousLocalizedGreeting;
  static String _previousStrGreeting = '';
  String get current {
    final now = DateTime.now();

    final int randomNumber = _nextRandom();
    LocalizedTextModel text;
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

  static const morning = LocalizedTextModel(
    en: 'Good morning',
    ru: 'Доброе утро',
    it: 'Buon giorno',
    ga: 'Maidin mhaith',
  );
  static const day = LocalizedTextModel(
    en: 'Good afternoon',
    ru: 'Добрый день',
    it: 'Buona giornata',
    ga: 'Lá maith',
  );
  static const evening = LocalizedTextModel(
    en: 'Good evening',
    ru: 'Добрый вечер',
    it: 'Buona serata',
    ga: 'Tráthnóna maith',
  );
  static const night = LocalizedTextModel(
    en: 'Good night',
    ru: 'Доброй ночи',
    it: 'Buona notte',
    ga: 'Oíche mhaith',
  );
}
