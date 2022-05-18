enum DiffConflictPolicy {
  replaceByActiveDevice,
}

typedef ToDiffCallback = String Function();

abstract class Differable {}

abstract class Diff<T, TOther> {
  const Diff({
    required this.original,
    required this.other,
  });
  final T original;
  final TOther other;
}

class StringMergeDiff<T, TOther> extends Diff<T, TOther> {
  StringMergeDiff({
    required final T original,
    required final TOther other,
  }) : super(original: original, other: other);
}

class DiffUpdater<T extends Differable, TOther extends Differable> {
  DiffUpdater.of({
    required this.list,
    this.policy = DiffConflictPolicy.replaceByActiveDevice,
  });
  final Iterable<T> list;
  final DiffConflictPolicy policy;

  Iterable<T> updateByOther(
    final Iterable<TOther> otherList,
  ) {
    return [];
  }

  void compareContent() {}

  /// Compares the elements of the lists,
  ///
  void compareConsistency() {
    /// Generate a id map
  }
}
