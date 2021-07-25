import 'package:json_annotation/json_annotation.dart';

part 'locale_tile.g.dart';

@JsonSerializable()
class LocaleTitle {
  final String ru;
  final String en;
  const LocaleTitle({
    required this.en,
    required this.ru,
  });
  String getProp(String key) => <String, String>{'ru': ru, 'en': en}[key] ?? '';

  factory LocaleTitle.fromJson(Map<String, dynamic> json) =>
      _$LocaleTitleFromJson(json);
  Map<String, dynamic> toJson() => _$LocaleTitleToJson(this);
}
