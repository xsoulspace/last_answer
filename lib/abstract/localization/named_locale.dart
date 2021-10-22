part of abstract;

/// Use this class to show user a list of supported [Languages]
/// and let him to choose one of them
@immutable
class NamedLocale {
  const NamedLocale({
    required final this.name,
    required final this.locale,
  });

  /// this field will be shown to user
  final String name;

  /// this locale will be used as value to change a locale
  final Locale locale;

  /// this field is a [Locale.languageCode]
  String get code => locale.languageCode;
}
