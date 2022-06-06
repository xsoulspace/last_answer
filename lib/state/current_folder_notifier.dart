part of notifiers;

CurrentFolderNotifier createCurrentFoldersNotifier(
  final BuildContext context,
) =>
    CurrentFolderNotifier(ProjectFolder.zero());

class CurrentFolderNotifier extends ChangeNotifier {
  CurrentFolderNotifier(final this.state);
  ProjectFolder state;
  void setState(final ProjectFolder folder) {
    state = folder;
    notifyListeners();
  }

  void notify() => notifyListeners();

  void setExistedProjects(final Iterable<BasicProject> projects) {
    state.setExistedProjects(projects);
    notifyListeners();
  }
}
