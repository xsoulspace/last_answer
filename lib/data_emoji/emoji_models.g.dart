// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmojiModel _$EmojiModelFromJson(Map<String, dynamic> json) => _EmojiModel(
  category: json['category'] as String,
  emoji: json['emoji'] as String,
  keywords: json['keywords'] as String,
);

Map<String, dynamic> _$EmojiModelToJson(_EmojiModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'emoji': instance.emoji,
      'keywords': instance.keywords,
    };
