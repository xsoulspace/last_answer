import 'package:flutter/widgets.dart';

class Locales {
  static const Locale en = Locale(Languages.en, 'EN');
  static const Locale ru = Locale(Languages.ru, 'RU');
}

class Languages {
  static const String ru = 'ru';
  static const String en = 'en';
  static const List items = [
    ru,
    en,
  ];
  static List get all => items;
}
