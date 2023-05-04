part of 'localization.dart';

class Locales {
  Locales._();
  static const en = Locale('en', 'EN');
  static const ru = Locale('ru', 'RU');
  static const it = Locale('it', 'IT');

  /// Irland Language
  // static const ga = 'ga';

  /// Turkey Language
  // static const ga = 'ga';

  // static const ga = Locale(Languages.ga, 'GA');
  static const values = <Locale>[en, ru, it];
  static Locale byLanguage(final Languages language) {
    switch (language) {
      case Languages.en:
        return en;
      case Languages.ru:
        return ru;
      case Languages.it:
        return it;
    }
  }
}

typedef LanguageName = String;

enum Languages {
  ru('ru'),
  en('en'),
  it('it');

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
