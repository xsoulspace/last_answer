part of abstract;

@immutable
@JsonSerializable()
class Emoji {
  const Emoji({
    required final this.category,
    required final this.emoji,
    required final this.keywords,
  });
  static Emoji fromJson(final Map<String, dynamic> json) =>
      _$EmojiFromJson(json);
  Map<String, dynamic> toJson() => _$EmojiToJson(this);
  final String category;
  final String emoji;
  final String keywords;
}
