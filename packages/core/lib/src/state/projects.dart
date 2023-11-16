import 'package:flutter/cupertino.dart';

import '../datasources/datasources.dart';
import 'map_state.dart';

final class IdeaProjectsState extends MapState<IdeaProject> {}

IdeaProjectsState createIdeaProjectsState(final BuildContext context) =>
    IdeaProjectsState();

final class IdeaProjectQuestionsState extends MapState<IdeaProjectQuestion> {}

IdeaProjectQuestionsState createIdeaProjectQuestionsState(
  final BuildContext context,
) =>
    IdeaProjectQuestionsState();

final class NoteProjectsState extends MapState<NoteProject> {}

NoteProjectsState createNoteProjectsState(final BuildContext context) =>
    NoteProjectsState();
