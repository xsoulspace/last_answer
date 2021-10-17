part of providers;

final ideaProjectsProvider = StateProvider<Map<ProjectId, IdeaProject>>(
  (final _) => <ProjectId, IdeaProject>{},
);

final ideaProjectQuestionsProvider =
    StateProvider<List<IdeaProjectQuestion>>((final _) => []);

final noteProjectsProvider = StateProvider<Map<ProjectId, NoteProject>>(
  (final _) => <ProjectId, NoteProject>{},
);
final allProjectsProviders = Provider<AllProjectsController>(
  (final ref) => AllProjectsController(ref: ref),
);

class AllProjectsController {
  AllProjectsController({required final this.ref});
  ProviderRef<AllProjectsController> ref;
  List<BasicProject> get all {
    final _all = <BasicProject>[];
    void _addProject(final BasicProject project) {
      _all.add(project);
    }

    final ideas = ref.read(ideaProjectsProvider);
    final notes = ref.read(noteProjectsProvider);
    notes.state.values.forEach(_addProject);
    ideas.state.values.forEach(_addProject);
    _all.sort((final p1, final p2) => p1.updated.compareTo(p2.updated));
    return _all;
  }
}
