part of 'models.dart';

@freezed
class EmojiModel with _$EmojiModel {
  const factory EmojiModel({
    required final String category,
    required final String emoji,
    required final String keywords,
  }) = _EmojiModel;
  factory EmojiModel.fromJson(final Map<String, dynamic> json) =>
      _$EmojiModelFromJson(json);
}
