part of providers;

final projectsFoldersProvider =
    MapState<ProjectFolder>().inj(autoDisposeWhenNotUsed: false);

final currentFolderProvider =
    FolderState(ProjectFolder.zero()).inj(autoDisposeWhenNotUsed: false);

class FolderState {
  FolderState(final this.state);
  ProjectFolder state;
  void setExistedProjectsList(final Iterable<BasicProject> projects) =>
      state.setExistedProjectsList(projects);
}

final currentFolderProjects = RM.inject<List<BasicProject>>(
  () => currentFolderProvider.state.state.projectsList,
  autoDisposeWhenNotUsed: false,
  dependsOn: DependsOn({currentFolderProvider}),
);
