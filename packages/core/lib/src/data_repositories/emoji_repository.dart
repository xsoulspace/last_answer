import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

final class LastUsedEmojiRepository
    extends MapBasedRepository<String, EmojiModel>
    implements LastUsedEmojiLocalDataSource {
  LastUsedEmojiRepository.provide(final BuildContext context)
      : _datasource = context.read();
  final LastUsedEmojiLocalDataSource _datasource;

  @override
  void putAll(final Map<String, EmojiModel> map) => _datasource.putAll(map);
  @override
  Map<String, EmojiModel> getAll() => _datasource.getAll();
}

final class EmojiRepository {
  EmojiRepository.provide(final BuildContext context)
      : _datasource = context.read();
  final EmojiLocalDataSource _datasource;
  Future<Iterable<EmojiModel>> getAllEmoji() => _datasource.getAllEmoji();
  Future<Iterable<EmojiModel>> getSpecialEmoji() => _datasource.getAllEmoji();
}
