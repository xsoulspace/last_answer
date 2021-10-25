part of providers;

class MapState<TValue> extends StateNotifier<Map<String, TValue>> {
  MapState() : super({});

  void put({required final String key, required final TValue value}) =>
      state = {
        ...state,
        key: value,
      };
  void putAll(final Map<String, TValue> map) => state = {
        ...state,
        ...map,
      };
  void putEntries(final Iterable<MapEntry<String, TValue>> newEntries) =>
      state = {...state}..addEntries(newEntries);

  void remove({required final String key}) => state = {
        ...state,
      }..remove(key);
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
