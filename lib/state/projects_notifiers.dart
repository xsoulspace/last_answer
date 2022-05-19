part of notifiers;

class IdeaProjectsNotifier extends MapState<IdeaProject> {}

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
