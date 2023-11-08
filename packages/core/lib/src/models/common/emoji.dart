part of 'common.dart';

@freezed
class Emoji with _$Emoji {
  const factory Emoji({
    required final String category,
    required final String emoji,
    required final String keywords,
  }) = _Emoji;
  factory Emoji.fromJson(final Map<String, dynamic> json) =>
      _$EmojiFromJson(json);
}
