part of abstract;

/// Any text, that should be shown to user in different [Languages]
/// should use this class to keep values
@JsonSerializable()
@HiveType(typeId: HiveBoxesIds.localizedText)
class LocalizedText {
  const LocalizedText({
    required final this.en,
    required final this.ru,
    required final this.it,
  });
  factory LocalizedText.fromJson(final Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizedTextToJson(this);

  @HiveField(0)
  final String ru;
  @HiveField(1)
  final String en;
  @HiveField(2)
  final String it;

  /// If any new [Languages] added, add this to [values]
  Map<LanguageName, String?> get values => {
        Locales.ru.toString(): ru,
        Locales.en.toString(): en,
        Locales.it.toString(): it
      };
  String getByLanguage(final LanguageName language) => values[language] ?? en;
}
