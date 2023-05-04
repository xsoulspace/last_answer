import 'package:flutter/cupertino.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/state/map_state.dart';

class ProjectFoldersNotifier extends MapState<ProjectFolder> {}

ProjectFoldersNotifier createFoldersNotifier(final BuildContext context) =>
    ProjectFoldersNotifier();
