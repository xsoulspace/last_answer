part of abstract;

/// Any text, that should be shown to user in different [Languages]
/// should use this class to keep values
@immutable
@JsonSerializable()
class LocalizedText {
  const LocalizedText({
    required final this.en,
    required final this.ru,
  });

  final String ru;
  final String en;

  /// If any new [Languages] added, add this to [values]
  Map<LanguageName, String?> get values => {Languages.ru: ru, Languages.en: en};
  String getByLanguage(final LanguageName language) => values[language] ?? '';

  factory LocalizedText.fromJson(final Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizedTextToJson(this);
}
