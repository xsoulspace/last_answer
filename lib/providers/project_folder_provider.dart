part of providers;

final projectsFoldersProvider =
    MapState<ProjectFolder>().inj(autoDisposeWhenNotUsed: false);

final currentFolderProvider = RM.inject<FolderState>(
  () => FolderState(ProjectFolder.zero()),
  autoDisposeWhenNotUsed: false,
  dependsOn: DependsOn({
    ideaProjectsProvider,
    noteProjectsProvider,
  }),
  stateInterceptor: (currentSnap, nextSnap) {
    print('${currentSnap.state.state.id}, ${nextSnap.state.state.id}');
    return nextSnap;
  },
);

class FolderState {
  FolderState(final this.state);
  ProjectFolder state;
  void setExistedProjects(final Iterable<BasicProject> projects) =>
      state.setExistedProjects(projects);
}

final currentFolderProjects = RM.inject<List<BasicProject>>(
  () => currentFolderProvider.state.state.projectsList,
  autoDisposeWhenNotUsed: false,
  dependsOn: DependsOn({currentFolderProvider}),
);
