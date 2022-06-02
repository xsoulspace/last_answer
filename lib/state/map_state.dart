part of notifiers;

typedef OnFilterCallback<TValue> = bool Function(TValue value, String keyword);

typedef SaveUtil<TValue> = AbstractUtil<Map<String, TValue>>;

class MapState<TValue> extends ChangeNotifier {
  MapState({
    final this.saveUtil,
    final this.onFilter,
  });
  void notify() => notifyListeners();

  Map<String, TValue> state = {};

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
  final SaveUtil<TValue>? saveUtil;

  List<TValue> get values => state.values.toList();
  List<TValue> get filteredValues {
    final list = [...values];
    if (onFilter != null) {
      list.retainWhere((final v) => onFilter!(v, _filterKeyword));
    }

    return list;
  }

  void put({required final String key, required final TValue value}) {
    state[key] = value;
    notifyListeners();
    _save();
  }

  Future<void> _save() async => saveUtil?.save(state);

  void putAll(final Map<String, TValue> map) {
    state.addAll(map);
    notifyListeners();
    _save();
  }

  void putEntries(final Iterable<MapEntry<String, TValue>> newEntries) {
    state.addEntries(newEntries);
    notifyListeners();
    _save();
  }

  void remove({required final String key}) {
    state.remove(key);
    notifyListeners();
    _save();
  }

  void removeByKeys({required final Iterable<String> keys}) {
    for (final key in keys) {
      state.remove(key);
    }
    notifyListeners();
    _save();
  }

  void assignAll(final Map<String, TValue> map) {
    state = map;
    _save();
  }

  void assignEntries(final Iterable<MapEntry<String, TValue>> newEntries) {
    state = Map.fromEntries(newEntries);
    notifyListeners();
    _save();
  }

  void loadIterable(final Iterable<TValue> values) {
    if (values.isEmpty) {
      assignAll({});
    } else {
      assignEntries(
        values.map((final e) {
          if (e is HasId) {
            return MapEntry(e.id, e);
          } else {
            throw UnimplementedError('Provide HasId interface to load type');
          }
        }),
      );
    }
  }

  static TProvider load<TValue, TProvider extends MapState<TValue>>({
    required final BuildContext context,
    required final Box<TValue> box,
  }) {
    return context.read<TProvider>()..loadIterable(box.values);
  }
}
