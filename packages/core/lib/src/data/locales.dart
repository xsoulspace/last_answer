import 'package:flutter/cupertino.dart';

import '../../core.dart';

typedef LanguageName = String;

enum Languages {
  ru('ru'),
  en('en'),
  it('it'),
  // ga('ga')
  ;

  const Languages(this.value);
  final String value;
  static Languages byLanguageCode(final String languageCode) {
    try {
      return all.byName(languageCode.toLowerCase());
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return Languages.en;
    }
  }

  static const all = <Languages>[ru, en, it];
}

class Locales {
  Locales._();
  static const en = Locale('en', 'EN');
  static const ru = Locale('ru', 'RU');
  static const it = Locale('it', 'IT');

  /// Irland Language
  // static const ga = Locale('ga', 'GA');

  /// Turkey Language
  static const values = <Locale>[en, ru, it];
  // ga];
  static Locale byLanguage(final Languages language) => switch (language) {
        Languages.en => en,
        Languages.ru => ru,
        Languages.it => it,
        // Languages.ga => ga,
      };
}

final Map<Languages, NamedLocale> namedLocalesMap = {
  Languages.en: const NamedLocale(
    name: 'English',
    locale: Locales.en,
  ),
  Languages.ru: const NamedLocale(
    name: 'Русский',
    locale: Locales.ru,
  ),
  Languages.it: const NamedLocale(
    name: 'Italian',
    locale: Locales.it,
  ),
};

String getLanguageCodeByStr(final LanguageName language) {
  String lang = language;
  if (language.contains('_')) {
    lang = language.split('_').first;
  }

  return lang;
}
