import 'package:flutter/cupertino.dart';

import '../datasources/datasources.dart';
import 'map_state.dart';

class IdeaProjectsState extends MapState<IdeaProject> {}

IdeaProjectsState createIdeaProjectsState(final BuildContext context) =>
    IdeaProjectsState();

class IdeaProjectQuestionsState extends MapState<IdeaProjectQuestion> {}

IdeaProjectQuestionsState createIdeaProjectQuestionsState(
  final BuildContext context,
) =>
    IdeaProjectQuestionsState();

class NoteProjectsState extends MapState<NoteProject> {}

NoteProjectsState createNoteProjectsState(final BuildContext context) =>
    NoteProjectsState();
