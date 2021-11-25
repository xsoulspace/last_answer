part of providers;

class MapState<TValue> extends StateNotifier<Map<String, TValue>> {
  MapState({final this.saveUtil}) : super({});

  final AbstractUtil<Map<String, TValue>>? saveUtil;
  Map<String, TValue> get safeState => state;

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

  static MapState<TValue> load<TValue>({
    required final WidgetRef ref,
    required final MapStateProvider<TValue> provider,
    required final Box<TValue> box,
  }) =>
      ref.read(provider.notifier)..loadIterable(box.values);

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

typedef MapStateProvider<TValue>
    = StateNotifierProvider<MapState<TValue>, Map<String, TValue>>;
