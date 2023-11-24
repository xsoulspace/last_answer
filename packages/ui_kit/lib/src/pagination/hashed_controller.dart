import 'dart:collection';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HashPagingController<TKey, TItem> extends PagingController<TKey, TItem> {
  HashPagingController({
    required super.firstPageKey,
    super.invisibleItemsThreshold,
  });

  /// Appends [newItems] to the previously loaded ones and sets the next page
  /// key to `null`.
  void prependLastPage(final List<TItem> newItems) =>
      prependPage(newItems, null);

  void prependPage(final List<TItem> newItems, final TKey? nextPageKey) {
    if (!_mounted) return;
    final previousItems = LinkedHashSet<TItem>(
      hashCode: (final e) => e.hashCode,
      equals: (final a, final b) => a.hashCode == b.hashCode,
    )
      ..addAll(newItems)
      ..addAll(value.itemList ?? []);
    value = PagingState<TKey, TItem>(
      itemList: previousItems.toList(),
      nextPageKey: nextPageKey,
    );
  }

  @override
  void appendPage(final List<TItem> newItems, final TKey? nextPageKey) {
    if (!_mounted) return;
    final previousItems = LinkedHashSet<TItem>(
      hashCode: (final e) => e.hashCode,
      equals: (final a, final b) => a.hashCode == b.hashCode,
    )
      ..addAll(value.itemList ?? [])
      ..addAll(newItems);
    value = PagingState<TKey, TItem>(
      itemList: previousItems.toList(),
      nextPageKey: nextPageKey,
    );
  }

  void insertElement(
    final TItem element, {
    final int at = 0,
  }) {
    final newItems = [...?itemList]..insert(at, element);

    value = value.copyWith(
      itemList: newItems,
    );
  }

  void insertElements(
    final Iterable<TItem> elements, {
    final int at = 0,
  }) {
    final newItems = [...?itemList]..insertAll(at, elements);

    value = value.copyWith(
      itemList: newItems,
    );
  }

  /// removes element from listing at given [index], then reinserts it
  /// at [moveToIndex]
  void moveElementByIndex({
    required final int index,
    required final TItem element,

    /// target index after element removal
    final int moveToIndex = 0,
  }) {
    if (index < 0) return;
    final newItems = [...?itemList]
      ..removeAt(index)
      ..insert(moveToIndex, element);
    value = value.copyWith(
      itemList: newItems,
    );
  }

  /// removes element from listing at given [index]
  TItem? removeElementByIndex({
    required final int index,
  }) {
    if (index < 0) return null;
    final items = itemList ?? [];
    if (items.isEmpty) return null;
    final item = items[index];
    final newItems = [...items]..removeAt(index);
    value = value.copyWith(
      itemList: newItems,
    );
    return item;
  }

  TItem? removeElementWhere({
    required final bool Function(TItem element) test,
  }) {
    final int index = value.itemList?.indexWhere(test) ?? -1;
    return removeElementByIndex(index: index);
  }

  List<TItem> removeElementsWhere({
    required final bool Function(TItem element) test,
  }) {
    final list = [...?value.itemList];
    if (list.isEmpty) return [];
    final itemsToDelete = list.indexed.where((final e) => test(e.$2)).toList()
      ..sort(
        /// sort from max index to short index to
        /// make items removal easier
        (final indexEl1, final indexEl2) => indexEl2.$1.compareTo(indexEl1.$1),
      );
    final deletedItems = itemsToDelete
        .map((final e) => removeElementByIndex(index: e.$1))
        .whereType<TItem>()
        .toList();
    return deletedItems;
  }

  void removeElement({
    required final TItem element,
  }) {
    final int index =
        value.itemList?.indexWhere((final a) => a == element) ?? -1;
    removeElementByIndex(index: index);
  }

  void replaceElementByIndex({
    required final int index,
    required final TItem element,
    final bool shouldAddOnNotFound = false,
  }) {
    if (index < 0) {
      if (shouldAddOnNotFound) {
        insertElement(element);
      } else {
        return;
      }
    } else {
      final newItems = [...?itemList]
        ..removeAt(index)
        ..insert(index, element);
      value = value.copyWith(
        itemList: newItems,
      );
    }
  }

  void replaceElement({
    required final TItem element,
    final bool shouldAddOnNotFound = false,
    final bool Function(TItem a, TItem b)? equals,
    final int? index,
  }) {
    final bool Function(TItem) comparator = equals == null
        ? ((final a) => a == element)
        : (final a) => equals(a, element);
    final int eIndex = index ?? (value.itemList?.indexWhere(comparator) ?? -1);

    replaceElementByIndex(
      index: eIndex,
      element: element,
      shouldAddOnNotFound: shouldAddOnNotFound,
    );
  }

  bool _mounted = true;
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}

extension PagingStateExtension<TPageKey, TItem>
    on PagingState<TPageKey, TItem> {
  PagingState<TPageKey, TItem> copyWith({
    final dynamic error,
    final List<TItem>? itemList,
    final TPageKey? nextPageKey,
  }) =>
      PagingState(
        error: error ?? this.error,
        itemList: itemList ?? this.itemList,
        nextPageKey: nextPageKey ?? this.nextPageKey,
      );
}
