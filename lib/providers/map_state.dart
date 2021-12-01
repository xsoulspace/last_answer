part of providers;

class MapState<TValue> {
  MapState({final this.saveUtil});
  Map<String, TValue> state = {};

  final AbstractUtil<Map<String, TValue>>? saveUtil;
  Map<String, TValue> get safeState => state;
  List<TValue> get values => state.values.toList();

  void put({required final String key, required final TValue value}) {
    state[key] = value;
    _save();
  }

  Future<void> _save() async => saveUtil?.save(state);

  void putAll(final Map<String, TValue> map) {
    state.addAll(map);
    _save();
  }

  void putEntries(final Iterable<MapEntry<String, TValue>> newEntries) {
    state.addEntries(newEntries);
    _save();
  }

  void remove({required final String key}) {
    state.remove(key);
    _save();
  }

  void assignAll(final Map<String, TValue> map) {
    state = map;
    _save();
  }

  void assignEntries(final Iterable<MapEntry<String, TValue>> newEntries) {
    state = Map.fromEntries(newEntries);
    _save();
  }

  static MapState<TValue> load<TValue>({
    required final ReactiveModel<MapState<TValue>> provider,
    required final Box<TValue> box,
  }) {
    provider
      ..state.loadIterable(box.values)
      ..notify();
    return provider.state;
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
}
