part of providers;

final projectsFoldersProvider =
    StateNotifierProvider<MapState<ProjectFolder>, Map<String, ProjectFolder>>(
  (final _) => MapState<ProjectFolder>(),
);

class FolderState extends StateNotifier<ProjectFolder> {
  FolderState(final ProjectFolder folder) : super(folder);
  void setExistedProjectsList(final Iterable<BasicProject> projects) =>
      state = state..setExistedProjectsList(projects);
}

final currentFolderProvider = StateNotifierProvider<FolderState, ProjectFolder>(
  (final ref) => FolderState(ProjectFolder.zero()),
);

final currentFolderProjects = Provider<List<BasicProject>>(
  (final ref) {
    final currentFolder = ref.watch(currentFolderProvider);
    return currentFolder.projectsList;
  },
);
