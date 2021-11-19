part of providers;

final ideaProjectsProvider = StateNotifierProvider<MapState<IdeaProject>,
    Map<IdeaProjectId, IdeaProject>>(
  (final _) => MapState<IdeaProject>(),
);

final ideaProjectQuestionsProvider = StateNotifierProvider<
    MapState<IdeaProjectQuestion>,
    Map<IdeaProjectQuestionId, IdeaProjectQuestion>>(
  (final _) => MapState<IdeaProjectQuestion>(),
);

final noteProjectsProvider = StateNotifierProvider<MapState<NoteProject>,
    Map<NoteProjectId, NoteProject>>(
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

// TODO(arenukvern): replace to another file

final projectsFoldersProvider =
    StateNotifierProvider<MapState<ProjectFolder>, Map<String, ProjectFolder>>(
  (final _) => MapState<ProjectFolder>(),
);

final currentFolderProjects = Provider<List<BasicProject>>((final ref) {
  const chosenFolderId = '';
  final folder = ref.watch(projectsFoldersProvider)[chosenFolderId];
  return folder?.projects ?? [];
});
