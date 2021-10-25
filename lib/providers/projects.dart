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

final ideaProjectsProvider =
    StateNotifierProvider<MapState<IdeaProject>, Map<String, IdeaProject>>(
  (final _) => MapState<IdeaProject>(),
);

final ideaProjectQuestionsProvider = StateNotifierProvider<
    MapState<IdeaProjectQuestion>, Map<String, IdeaProjectQuestion>>(
  (final _) => MapState<IdeaProjectQuestion>(),
);

final noteProjectsProvider =
    StateNotifierProvider<MapState<NoteProject>, Map<String, NoteProject>>(
  (final _) => MapState<NoteProject>(),
);

final allProjectsProviders = Provider<List<BasicProject>>(
  (final ref) {
    final _all = <BasicProject>[];
    void _addProject(final BasicProject project) {
      _all.add(project);
    }

    final ideas = ref.watch(ideaProjectsProvider);
    final notes = ref.watch(noteProjectsProvider);
    notes.values.forEach(_addProject);
    ideas.values.forEach(_addProject);
    _all.sort((final p1, final p2) => p1.updated.compareTo(p2.updated));
    return _all;
  },
);
