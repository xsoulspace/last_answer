part of 'hive_models.dart';

@immutable
@JsonSerializable()
class Emoji {
  const Emoji({
    required this.category,
    required this.emoji,
    required this.keywords,
  });
  factory Emoji.fromJson(final Map<String, dynamic> json) =>
      _$EmojiFromJson(json);
  Map<String, dynamic> toJson() => _$EmojiToJson(this);
  final String category;
  final String emoji;
  final String keywords;
}
