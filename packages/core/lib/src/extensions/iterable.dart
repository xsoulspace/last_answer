import 'package:collection/collection.dart';

extension IterableExt<TType> on Iterable<TType> {
  Map<TId, int> toIndexedMap<TId>(final TId Function(TType) toId) {
    final iterableEntries =
        mapIndexed((final index, final e) => MapEntry(toId(e), index));

    return Map.fromEntries(iterableEntries);
  }

  Map<TKey, TMapType> toMap<TKey, TMapType>({
    required final TKey Function(TType item) toKey,
    required final TMapType Function(TType item) toValue,
  }) {
    final iterableEntries = map((final e) {
      final key = toKey(e);
      final value = toValue(e);

      return MapEntry(key, value);
    });

    return Map.fromEntries(iterableEntries);
  }
}
