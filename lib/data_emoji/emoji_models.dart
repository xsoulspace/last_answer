import 'package:freezed_annotation/freezed_annotation.dart';

part 'emoji_models.freezed.dart';
part 'emoji_models.g.dart';

/// An emoji catalog row: the character, its display category, and a
/// space-separated keyword list for palette filtering (moved from
/// packages/shared_models, ADR 0038 — an app-domain model, never an RPC
/// payload).
@freezed
sealed class EmojiModel with _$EmojiModel {
  const factory EmojiModel({
    required final String category,
    required final String emoji,
    required final String keywords,
  }) = _EmojiModel;
  const EmojiModel._();
  factory EmojiModel.fromJson(final Map<String, dynamic> json) =>
      _$EmojiModelFromJson(json);
}
