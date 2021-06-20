import 'package:flutter/widgets.dart';

class Locales {
  static const Locale en = Locale(Languages.en, 'EN');
  static const Locale ru = Locale(Languages.ru, 'RU');
}

class Languages {
  static const ru = 'ru';
  static const en = 'en';
  static const items = [
    ru,
    en,
  ];
}
