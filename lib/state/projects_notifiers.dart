import 'package:flutter/cupertino.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/state/map_state.dart';

class IdeaProjectsNotifier extends MapState<IdeaProject> {}

IdeaProjectsNotifier createIdeaProjectsNotifier(final BuildContext context) =>
    IdeaProjectsNotifier();

class IdeaProjectAnswersNotifier extends MapState<IdeaProjectAnswer> {
  Iterable<IdeaProjectAnswer> getAllByIdea({
    required final ProjectId ideaId,
  }) {
    return state.values
        .where((final answer) => answer.projectId == ideaId)
        .toList()
      ..sort((final a, final b) => a.createdAt.compareTo(b.createdAt));
  }

  IdeaProjectAnswer getByIdea({
    required final IdeaProjectAnswerId answerId,
  }) {
    return state[answerId]!;
  }
}

IdeaProjectAnswersNotifier createIdeaProjectAnswersNotifier(
  final BuildContext context,
) =>
    IdeaProjectAnswersNotifier();

class IdeaProjectQuestionsNotifier extends MapState<IdeaProjectQuestion> {}

IdeaProjectQuestionsNotifier createIdeaProjectQuestionsProvider(
  final BuildContext context,
) =>
    IdeaProjectQuestionsNotifier();

class NoteProjectsNotifier extends MapState<NoteProject> {}

NoteProjectsNotifier createNoteProjectsNotifier(final BuildContext context) =>
    NoteProjectsNotifier();
