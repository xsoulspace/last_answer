part of abstract;

class Locales {
  Locales._();
  static const Locale en = Locale(Languages.en, 'EN');
  static const Locale ru = Locale(Languages.ru, 'RU');
  static const Locale it = Locale(Languages.it, 'IT');
  static const values = [en, ru, it];
}

class Languages {
  Languages._();
  static const ru = 'ru';
  static const en = 'en';
  static const it = 'it';
  static const values = [ru, en, it];
}
