import 'dart:ui';

class NamedLocale {
  final String name;
  final Locale locale;
  get localeCode => locale.languageCode;
  NamedLocale({required this.name, required this.locale});
}
