import 'package:flutter/cupertino.dart';

import '../models/hive_models/hive_models.dart';
import 'map_state.dart';

class ProjectsFolderProvider extends MapState<ProjectFolder> {}

ProjectsFolderProvider createProjectsFoldersProvider(
  final BuildContext context,
) =>
    ProjectsFolderProvider();

FolderStateProvider createCurrentFolderProvider(final BuildContext context) =>
    FolderStateProvider(ProjectFolder.zero());

class FolderStateProvider extends ChangeNotifier {
  FolderStateProvider(this.state);
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
