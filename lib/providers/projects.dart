part of providers;

final ideaProjectsProvider = StateProvider<Map<ProjectId, IdeaProject>>(
  (final _) => <ProjectId, IdeaProject>{},
);

final ideaProjectQuestionsProvider =
    StateProvider<List<IdeaProjectQuestion>>((final _) => []);

final noteProjectsProvider = StateProvider<Map<ProjectId, NoteProject>>(
  (final _) => <ProjectId, NoteProject>{},
);

final allProjectsProviders = Provider<List<BasicProject>>(
  (final ref) {
    final all = <BasicProject>[];
    void _addProject(final BasicProject project) {
      all.add(project);
    }

    final ideas = ref.watch(ideaProjectsProvider);
    final note = ref.watch(ideaProjectsProvider);
    note.state.values.forEach(_addProject);
    ideas.state.values.forEach(_addProject);
    all.sort((final p1, final p2) => p1.updated.compareTo(p2.updated));
    return all;
  },
);
