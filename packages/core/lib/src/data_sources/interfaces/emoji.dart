import 'package:flutter/widgets.dart';

import '../../data_models/data_models.dart';

abstract interface class LastUsedEmojiLocalDataSource {
  void putAll(final Map<String, EmojiModel> map);
  Map<String, EmojiModel> getAll();
}

abstract interface class EmojiLocalDataSource {
  Future<Iterable<EmojiModel>> getAllEmoji(
    final AssetBundle assetBundle,
  );
  Future<Iterable<EmojiModel>> getSpecialEmoji(
    final AssetBundle assetBundle,
  );
}
