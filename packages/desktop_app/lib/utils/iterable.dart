/// This extension contains common helpers for [Iterable]
extension IterableExt<E> on Iterable<E> {}

extension ListExt<TValue> on List<TValue> {
  List<TValue> reorder({
    final int oldIndex = 0,
    final int newIndex = 0,
  }) {
    int effectiveIndex = newIndex;
    final list = [...this];
    if (effectiveIndex > oldIndex) {
      effectiveIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(effectiveIndex, item);

    return list;
  }
}
