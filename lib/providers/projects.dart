part of providers;

final ideaProjectsProvider =
    MapState<IdeaProject>().inj(autoDisposeWhenNotUsed: false);

final ideaProjectQuestionsProvider =
    MapState<IdeaProjectQuestion>().inj(autoDisposeWhenNotUsed: false);

final noteProjectsProvider =
    MapState<NoteProject>().inj(autoDisposeWhenNotUsed: false);

final allProjectsProviders = RM.inject(
  () {
    final _all = <BasicProject>[];
    void _addProject(final BasicProject project) {
      _all.add(project);
    }

    final ideas = ideaProjectsProvider.state.state;
    final notes = noteProjectsProvider.state.state;
    notes.values.forEach(_addProject);
    ideas.values.forEach(_addProject);
    _all.sort((final p1, final p2) => p1.updated.compareTo(p2.updated));
    return _all;
  },
  dependsOn: DependsOn({
    ideaProjectsProvider,
    noteProjectsProvider,
  }),
  autoDisposeWhenNotUsed: false,
);
