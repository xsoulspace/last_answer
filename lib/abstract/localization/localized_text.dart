part of abstract;

/// Any text, that should be shown to user in different [Languages]
/// should use this class to keep values
@JsonSerializable()
@HiveType(typeId: HiveBoxesIds.localizedText)
class LocalizedText with EquatableMixin {
  const LocalizedText({
    required final this.en,
    required final this.ru,
    final this.it,
    final this.ga,
  });
  factory LocalizedText.fromJson(final Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizedTextToJson(this);

  /// Russian
  @HiveField(0)
  final String ru;

  /// English
  @HiveField(1)
  final String en;

  /// Italian
  @HiveField(2)
  final String? it;

  /// Irish
  @HiveField(3)
  final String? ga;

  /// If any new [Languages] added, add this to [values]
  Map<LanguageName, String?> get values => {
        Locales.ru.toString(): ru,
        Locales.en.toString(): en,
        Locales.it.toString(): it,
        Locales.ga.toString(): ga
      };
  String getByLanguage(final LanguageName language) => values[language] ?? en;

  @override
  List<Object?> get props => [ru, en, it, ga];
}
