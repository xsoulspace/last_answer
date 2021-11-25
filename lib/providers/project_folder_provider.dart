part of providers;

final projectsFoldersProvider =
    StateNotifierProvider<MapState<ProjectFolder>, Map<String, ProjectFolder>>(
  (final _) => MapState<ProjectFolder>(),
);

final currentFolderProvider = Provider<ProjectFolder>(
  (final ref) => ProjectFolder.zero(),
  dependencies: [projectsFoldersProvider],
);

final currentFolderProjects =
    Provider<UnmodifiableListView<BasicProject>>((final ref) {
  const chosenFolderId = '';
  final folder = ref.watch(projectsFoldersProvider)[chosenFolderId];
  return folder?.projectsList ?? UnmodifiableListView<BasicProject>([]);
});
