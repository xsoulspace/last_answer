part of providers;

class MapState<TValue> extends StateNotifier<Map<String, TValue>> {
  MapState({final this.saveUtil}) : super({});
  final AbstractUtil<Map<String, TValue>>? saveUtil;
  void put({required final String key, required final TValue value}) {
    state = {
      ...state,
      key: value,
    };
    _save();
  }

  Future<void> _save() async => saveUtil?.save(state);

  void putAll(final Map<String, TValue> map) {
    state = {
      ...state,
      ...map,
    };
    _save();
  }

  void putEntries(final Iterable<MapEntry<String, TValue>> newEntries) {
    state = {...state}..addEntries(newEntries);
    _save();
  }

  void remove({required final String key}) {
    state = {
      ...state,
    }..remove(key);
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
}
