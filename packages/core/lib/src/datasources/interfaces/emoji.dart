import 'package:flutter/widgets.dart';

import '../../models/models.dart';

abstract base class LastUsedEmojiLocalDataSource {
  void putAll(final Map<String, EmojiModel> map);
  Map<String, EmojiModel> getAll();
}

abstract base class EmojiLocalDataSource {
  Future<Iterable<EmojiModel>> getAllEmoji(
    final AssetBundle assetBundle,
  );
  Future<Iterable<EmojiModel>> getSpecialEmoji(
    final AssetBundle assetBundle,
  );
}
