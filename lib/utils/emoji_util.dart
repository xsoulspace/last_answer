part of utils;

class EmojiUtil extends ChangeNotifier {
  Future<Iterable<Emoji>> load(final BuildContext context) async {
    final emojisStr =
        await DefaultAssetBundle.of(context).loadString(Assets.emojis);
    final emojiList = jsonDecode(emojisStr) as List<Map<String, dynamic>>;
    return emojiList.map(Emoji.fromJson);
  }
}
