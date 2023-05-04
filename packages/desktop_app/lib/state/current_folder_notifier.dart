import 'package:flutter/cupertino.dart';
import 'package:lastanswer/abstract/abstract.dart';

CurrentFolderNotifier createCurrentFoldersNotifier(
  final BuildContext context,
) =>
    CurrentFolderNotifier(ProjectFolder.zero());

class CurrentFolderNotifier extends ChangeNotifier {
  CurrentFolderNotifier(this._state);
  ProjectFolder get state => _state;
  ProjectFolder _state;
  void setState(final ProjectFolder folder) {
    _state = folder;
    notifyListeners();
  }

  void notify() => notifyListeners();

  void setExistedProjects(final Iterable<BasicProject> projects) {
    _state.setExistedProjects(projects);
    notifyListeners();
  }
}
