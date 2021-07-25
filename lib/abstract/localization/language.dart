part of abstract;

class Locales {
  Locales._();
  static const en = Locale(Languages.en, 'EN');
  static const ru = Locale(Languages.ru, 'RU');
  static const it = Locale(Languages.it, 'IT');
  static const values = <Locale>[en, ru, it];
}

typedef LanguageName = String;

class Languages {
  Languages._();
  static const ru = 'ru';
  static const en = 'en';
  static const it = 'it';
  static const values = <LanguageName>[ru, en, it];
}
