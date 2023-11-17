import 'package:flutter/services.dart';

import '../../core.dart';

final class LastUsedEmojiRepository
    extends MapBasedRepository<String, EmojiModel>
    implements LastUsedEmojiLocalDataSource {
  LastUsedEmojiRepository({
    required this.localDataSource,
  });
  final LastUsedEmojiLocalDataSource localDataSource;

  @override
  void putAll(final Map<String, EmojiModel> map) => localDataSource.putAll(map);
  @override
  Map<String, EmojiModel> getAll() => localDataSource.getAll();
}

final class EmojiRepository {
  EmojiRepository({
    required this.localDataSource,
  });
  final EmojiLocalDataSource localDataSource;
  Future<Iterable<EmojiModel>> getAllEmoji(
    final AssetBundle assetBundle,
  ) =>
      localDataSource.getAllEmoji(assetBundle);
  Future<Iterable<EmojiModel>> getSpecialEmoji(
    final AssetBundle assetBundle,
  ) =>
      localDataSource.getAllEmoji(assetBundle);
}
