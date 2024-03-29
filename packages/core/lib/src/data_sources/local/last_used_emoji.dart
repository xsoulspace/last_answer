import 'package:shared_models/shared_models.dart';

import '../interfaces/interfaces.dart';
import 'local.dart';

final class LastUsedEmojiLocalDataSourceImpl
    implements LastUsedEmojiLocalDataSource {
  LastUsedEmojiLocalDataSourceImpl({
    required this.localDbDataSource,
  });
  final LocalDbDataSource localDbDataSource;

  @override
  Map<String, EmojiModel> getAll() {
    final map =
        localDbDataSource.getMap(SharedPreferencesKeys.lastUsedEmojis.name);
    if (map.isEmpty) return {};
    try {
      return Map.fromEntries(
        map.entries.map(
          (final e) => MapEntry(
            e.key,
            EmojiModel.fromJson(e.value as Map<String, dynamic>),
          ),
        ),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> putAll(final Map<String, EmojiModel> map) async {
    final effectiveMap = map.map(
      (final key, final value) => MapEntry(key, value.toJson()),
    );
    localDbDataSource.setMap(
      key: SharedPreferencesKeys.lastUsedEmojis.name,
      value: effectiveMap,
    );
  }
}
