import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../generated/generated.dart';
import '../../models/models.dart';
import '../interfaces/interfaces.dart';

final class EmojiLocalDataSourceImpl extends EmojiLocalDataSource {
  @override
  Future<Iterable<EmojiModel>> getAllEmoji(
    final AssetBundle assetBundle,
  ) async {
    final emojisStr = await assetBundle.loadString(
      Assets.json.emojis,
    );
    final emojiList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(emojisStr),
    );

    return emojiList.map(EmojiModel.fromJson);
  }

  /// use [DefaultAssetBundle.of(context)]
  @override
  Future<Iterable<EmojiModel>> getSpecialEmoji(
    final AssetBundle assetBundle,
  ) async {
    final emojisStr = await assetBundle.loadString(Assets.json.specialEmoji);
    final emojiList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(emojisStr),
    );

    return emojiList.map(EmojiModel.fromJson);
  }
}
