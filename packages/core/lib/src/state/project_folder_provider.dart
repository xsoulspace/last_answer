import 'package:flutter/cupertino.dart';

import '../datasources/datasources.dart';
import 'map_state.dart';

final class FolderState extends MapState<ProjectFolder> {}

FolderState createProjectsFoldersProvider(
  final BuildContext context,
) =>
    FolderState();

FolderStateNotifier createCurrentFolderProvider(final BuildContext context) =>
    FolderStateNotifier(ProjectFolder.zero());

class FolderStateNotifier extends ChangeNotifier {
  FolderStateNotifier(this.state);
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
