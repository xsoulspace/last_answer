part of abstract;

class NamedLocale {
  final String name;
  final Locale locale;
  String get localeCode => locale.languageCode;
  const NamedLocale({
    required this.name,
    required this.locale,
  });
}
