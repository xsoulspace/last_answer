part of 'utils.dart';

/// This extension contains common helpers for [Iterable]
extension IterableExt<E> on Iterable<E> {
  /// Returns the first element that satisfies the given predicate [test].
  ///
  /// Iterates through elements and returns the first to satisfy [test].
  ///
  /// If no element satisfies [test], the result will be [null]
  E? firstWhereOrNull(final bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
