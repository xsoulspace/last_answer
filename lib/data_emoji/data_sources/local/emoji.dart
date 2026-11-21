import 'dart:convert';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lastanswer/data_emoji/data_emoji.dart';
import 'package:lastanswer/foundation/generated/generated.dart';

final class EmojiLocalDataSourceImpl implements EmojiLocalDataSource {
  EmojiLocalDataSourceImpl({
    required this.assetBundle,
  });

  /// use [DefaultAssetBundle.of(context)]
  final AssetBundle assetBundle;

  @override
  Future<Iterable<EmojiModel>> getAllEmoji() async {
    final emojisStr = await assetBundle.loadString(
      Assets.json.emojis,
    );
    final emojiList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(emojisStr) as List<dynamic>,
    );

    return emojiList.map(EmojiModel.fromJson);
  }

  @override
  Future<Iterable<EmojiModel>> getSpecialEmoji() async {
    final emojisStr = await assetBundle.loadString(Assets.json.specialEmoji);
    final emojiList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(emojisStr) as List<dynamic>,
    );

    return emojiList.map(EmojiModel.fromJson);
  }
}
