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

class DiffFinder<T extends Differable, TOther extends Differable> {
  DiffFinder.of({
    required final Iterable<T> list,
    required final Iterable<TOther> otherList,
    this.policy = DiffConflictPolicy.replaceByActiveDevice,
  }) {
    changes = compare(list, otherList);
  }
  final DiffConflictPolicy policy;
  Iterable<Diff<T, TOther>> changes = [];
  Iterable<Diff<T, TOther>> compare(
    final Iterable<T> list,
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
