part of 'state.dart';

typedef OnFilterCallback<TValue> = bool Function(TValue value, String keyword);

/// analogue of ValueNotifier but wihout equality checks
base class MapStateNotifier<TValue> extends ChangeNotifier {
  MapStateNotifier({
    this.repository,
    this.onFilter,
  });
  void notify() => notifyListeners();

  LoadableContainer<Map<String, TValue>> state =
      const LoadableContainer(value: {});

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

  final OnFilterCallback<TValue>? onFilter;
  final MapBasedRepository<String, TValue>? repository;

  List<TValue> get values => state.value.values.toList();
  List<TValue> get filteredValues {
    final list = [...values];
    if (onFilter != null) {
      list.retainWhere((final v) => onFilter!(v, _filterKeyword));
    }

    return list;
  }

  void _save() => repository?.putAll(state.value);
  void setState(final Map<String, TValue> value) =>
      LoadableContainer.loaded(value);
  void put({required final String key, required final TValue value}) {
    setState({...state.value}..[key] = value);
    notifyListeners();
    _save();
  }

  void putAll(final Map<String, TValue> map) {
    setState({...state.value}..addAll(map));
    notifyListeners();
    _save();
  }

  void putEntries(final Iterable<MapEntry<String, TValue>> newEntries) {
    setState({...state.value}..addEntries(newEntries));
    notifyListeners();
    _save();
  }

  void remove({required final String key}) {
    setState({...state.value}..remove(key));
    notifyListeners();
    _save();
  }

  void assignAll(final Map<String, TValue> map) {
    setState({...map});
  }

  void assignEntries(final Iterable<MapEntry<String, TValue>> newEntries) {
    setState(Map.fromEntries(newEntries));
    notifyListeners();
    _save();
  }

  void loadIterable({
    required final Iterable<TValue> values,
    required final String Function(TValue) toKey,
  }) {
    if (values.isEmpty) {
      assignAll({});
    } else {
      assignEntries(
        values.map((final e) => MapEntry(toKey(e), e)),
      );
    }
  }
}
