// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emoji _$EmojiFromJson(Map<String, dynamic> json) => Emoji(
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      keywords: json['keywords'] as String,
    );

Map<String, dynamic> _$EmojiToJson(Emoji instance) => <String, dynamic>{
      'category': instance.category,
      'emoji': instance.emoji,
      'keywords': instance.keywords,
    };
