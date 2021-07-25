part of abstract;

@JsonSerializable()
class LocaleTitle {
  final String ru;
  final String en;
  const LocaleTitle({
    required this.en,
    required this.ru,
  });
  String getProp(final String key) =>
      <String, String>{'ru': ru, 'en': en}[key] ?? '';

  factory LocaleTitle.fromJson(final Map<String, dynamic> json) =>
      _$LocaleTitleFromJson(json);
  Map<String, dynamic> toJson() => _$LocaleTitleToJson(this);
}
