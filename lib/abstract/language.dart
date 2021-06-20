import 'package:flutter/widgets.dart';

class Locales {
  static const Locale en = Locale(Languages.en, 'EN');
  static const Locale ru = Locale(Languages.ru, 'RU');
  static const Locale it = Locale(Languages.it, 'IT');
  static const all = [en, ru, it];
}

class Languages {
  static const ru = 'ru';
  static const en = 'en';
  static const it = 'it';
  static const all = [ru, en, it];
}
