part of providers;

class ProjectsFolderProvider extends MapState<ProjectFolder> {}

ProjectsFolderProvider createProjectsFoldersProvider(
  final BuildContext context,
) =>
    ProjectsFolderProvider();

FolderStateProvider createCurrentFolderProvider(final BuildContext context) =>
    FolderStateProvider(ProjectFolder.zero());

class FolderStateProvider extends ChangeNotifier {
  FolderStateProvider(final this.state);
  ProjectFolder state;
  void setState(final ProjectFolder folder) {
    state = folder;
    notifyListeners();
  }

  void setExistedProjects(final Iterable<BasicProject> projects) {
    state.setExistedProjects(projects);
    notifyListeners();
  }
}
