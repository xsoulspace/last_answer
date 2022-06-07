import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/utils/abstract_util.dart';
import 'package:lastanswer/utils/shared_preferences_keys.dart';
import 'package:lastanswer/utils/shared_preferences_util.dart';

class EmojiUtil
    with SharedPreferencesUtil
    implements AbstractUtil<Map<String, Emoji>> {
  EmojiUtil();
  static Future<Iterable<Emoji>> getList(final BuildContext context) async {
    final emojisStr =
        await DefaultAssetBundle.of(context).loadString(Assets.json.emojis);
    final emojiList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(emojisStr),
    );

    return emojiList.map(Emoji.fromJson);
  }

  static Future<Iterable<Emoji>> getSpecialList(
    final BuildContext context,
  ) async {
    final emojisStr = await DefaultAssetBundle.of(context)
        .loadString(Assets.json.specialEmoji);
    final emojiList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(emojisStr),
    );

    return emojiList.map(Emoji.fromJson);
  }

  @override
  Future<Map<String, Emoji>> load() async {
    final map = await getMap(SharedPreferencesKeys.lastUsedEmojis.name);
    if (map.isEmpty) return {};
    try {
      return Map.fromEntries(
        map.entries.map(
          (final e) => MapEntry(e.key, Emoji.fromJson(e.value)),
        ),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> save(final Map<String, Emoji> map) async {
    final effectiveMap = map.map(
      (final key, final value) => MapEntry(key, value.toJson()),
    );
    await setMap(SharedPreferencesKeys.lastUsedEmojis.name, effectiveMap);
  }
}
