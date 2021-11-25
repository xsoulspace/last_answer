part of providers;

final projectsFoldersProvider =
    StateNotifierProvider<MapState<ProjectFolder>, Map<String, ProjectFolder>>(
  (final _) => MapState<ProjectFolder>(),
);

final currentFolderProvider = StateProvider<ProjectFolder>(
  (final ref) => ProjectFolder.zero(),
  dependencies: [projectsFoldersProvider],
);

final currentFolderProjects = Provider<UnmodifiableListView<BasicProject>>(
  (final ref) {
    final currentFolder = ref.watch(currentFolderProvider);
    return currentFolder.state.projectsList;
  },
);
