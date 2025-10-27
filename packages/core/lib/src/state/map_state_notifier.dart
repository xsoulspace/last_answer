part of 'state.dart';

typedef OnFilterCallback<TValue> = bool Function(TValue value, String keyword);

/// analogue of ValueNotifier but without equality checks
base class MapStateNotifier<K, V> extends OrderedMapNotifier<K, V> {
  MapStateNotifier({this.onFilter, super.toKey});

  LoadableContainer<Map<K, V>> state = const LoadableContainer(value: {});

  /// Use [filterKeyword] to get filtered values
  String _filterKeyword = '';

  /// Use [filterKeyword] to get filtered values
  String get filterKeyword => _filterKeyword;

  /// Use [filterKeyword] to get filtered values
  set filterKeyword(final String filterKeyword) {
    if (_filterKeyword == filterKeyword) return;
    _filterKeyword = filterKeyword;
    notifyListeners();
  }

  // ignore: unsafe_variance
  final OnFilterCallback<V>? onFilter;

  List<V> get filteredValues {
    final list = [...orderedValues];
    if (onFilter != null) {
      list.retainWhere((final v) => onFilter!(v, _filterKeyword));
    }

    return list;
  }
}
