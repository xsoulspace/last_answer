import 'package:lastanswer/data_emoji/data_emoji.dart';

abstract interface class LastUsedEmojiLocalDataSource {
  Future<void> putAll(final Map<String, EmojiModel> map);
  Future<Map<String, EmojiModel>> getAll();
}

abstract interface class EmojiLocalDataSource {
  Future<Iterable<EmojiModel>> getAllEmoji();
  Future<Iterable<EmojiModel>> getSpecialEmoji();
}
