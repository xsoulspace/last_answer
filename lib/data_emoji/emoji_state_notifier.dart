import 'dart:async';
import 'dart:convert' show JsonDecoder, Utf8Decoder;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:la_ui_kit/la_ui_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_state_utils/xsoulspace_state_utils.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';
import 'package:lastanswer/foundation/foundation.dart';
import 'emoji_repository.dart';


final class EmojiStateNotifier extends MapStateNotifier<String, EmojiModel> {
  EmojiStateNotifier(final BuildContext context)
    : super(
        toKey: (final e) => e.emoji,
        onFilter: (final emoji, final keyword) =>
            keyword.isEmpty || emoji.keywords.contains(keyword),
      );
}

final class LastEmojiStateNotifier
    extends MapStateNotifier<String, EmojiModel> {
  LastEmojiStateNotifier(final BuildContext context)
    : lastUsedEmojiRepository = context.read(),
      super(toKey: (final e) => e.emoji);
  final LastUsedEmojiRepository lastUsedEmojiRepository;
}

final class SpecialEmojiStateNotifier
    extends MapStateNotifier<String, EmojiModel> {
  SpecialEmojiStateNotifier(final BuildContext context)
    : super(toKey: (final e) => e.emoji);
}
