part of providers;

final projectsFoldersProvider =
    MapState<ProjectFolder>().inj(autoDisposeWhenNotUsed: false);

final currentFolderProvider =
    FolderState(ProjectFolder.zero()).inj(autoDisposeWhenNotUsed: false);

class FolderState {
  FolderState(final this.state);
  ProjectFolder state;
  void setExistedProjects(final Iterable<BasicProject> projects) =>
      state.setExistedProjects(projects);
}

List<BasicProject> get currentFolderProjects =>
    currentFolderProvider.state.state.projectsList;
