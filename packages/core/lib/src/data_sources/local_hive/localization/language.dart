import 'dart:ui';

import 'named_locale.dart';

class Locales {
  Locales._();
  static final en = Locale(Languages.en.name, 'EN');
  static final ru = Locale(Languages.ru.name, 'RU');
  static final it = Locale(Languages.it.name, 'IT');
  static final ga = Locale(Languages.ga.name, 'GA');
  static final values = <Locale>[en, ru, it];
}

typedef LanguageName = String;

enum Languages { ru, en, it, ga }

final Map<Languages, NamedLocale> namedLocalesMap = {
  Languages.en: NamedLocale(
    name: 'English',
    locale: Locales.en,
  ),
  Languages.ru: NamedLocale(
    name: 'Русский',
    locale: Locales.ru,
  ),
  Languages.it: NamedLocale(
    name: 'Italian',
    locale: Locales.it,
  ),
};
