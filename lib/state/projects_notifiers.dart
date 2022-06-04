part of notifiers;

class IdeaProjectsNotifier extends MapState<IdeaProject> {}

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

IdeaProjectsNotifier createIdeaProjectsNotifier(final BuildContext context) =>
    IdeaProjectsNotifier();

class IdeaProjectQuestionsNotifier extends MapState<IdeaProjectQuestion> {}

IdeaProjectQuestionsNotifier createIdeaProjectQuestionsProvider(
  final BuildContext context,
) =>
    IdeaProjectQuestionsNotifier();

class NoteProjectsNotifier extends MapState<NoteProject> {}

NoteProjectsNotifier createNoteProjectsNotifier(final BuildContext context) =>
    NoteProjectsNotifier();
