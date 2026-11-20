import 'package:shared_models/shared_models.dart';

abstract interface class LastUsedEmojiLocalDataSource {
  Future<void> putAll(final Map<String, EmojiModel> map);
  Future<Map<String, EmojiModel>> getAll();
}

abstract interface class EmojiLocalDataSource {
  Future<Iterable<EmojiModel>> getAllEmoji();
  Future<Iterable<EmojiModel>> getSpecialEmoji();
}
