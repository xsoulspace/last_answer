part of pack_core;

Map<InstanceId, T> listWithIdToMap<T extends HasId>(
  final Iterable<T> list, {
  final bool Function(T element)? where,
}) {
  Iterable<T> newList = list;
  if (where != null) {
    newList = newList.where(where);
  }

  return Map.fromEntries(
    newList.map((final e) => MapEntry(e.id, e)),
  );
}
