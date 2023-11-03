import 'package:flutter/cupertino.dart';

import '../datasources/datasources.dart';
import 'map_state.dart';

class IdeaProjectsProvider extends MapState<IdeaProject> {}

IdeaProjectsProvider createIdeaProjectsProvider(final BuildContext context) =>
    IdeaProjectsProvider();

class IdeaProjectQuestionsProvider extends MapState<IdeaProjectQuestion> {}

IdeaProjectQuestionsProvider createIdeaProjectQuestionsProvider(
  final BuildContext context,
) =>
    IdeaProjectQuestionsProvider();

class NoteProjectsProvider extends MapState<NoteProject> {}

NoteProjectsProvider createNoteProjectsProvider(final BuildContext context) =>
    NoteProjectsProvider();
