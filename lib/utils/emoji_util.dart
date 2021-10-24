part of utils;

class EmojiUtil {
  EmojiUtil._();
  static Future<Iterable<Emoji>> getList(final BuildContext context) async {
    final emojisStr =
        await DefaultAssetBundle.of(context).loadString(Assets.emojis);
    final emojiList = List.castFrom<dynamic, Map<String, dynamic>>(
      jsonDecode(emojisStr),
    );
    return emojiList.map(Emoji.fromJson);
  }
}