part of app_navigator;

class AppNavigatorController {
  AppNavigatorController.use({
    required final this.routeState,
    required final this.ref,
  });
  final RouteState routeState;
  final WidgetRef ref;

  void goHome() => routeState.go(AppRoutesName.home);
  void goAppInfo() => routeState.go(AppRoutesName.appInfo);
  void goSettings() => routeState.go(AppRoutesName.settings);

  Future<void> goNoteScreen({final String? noteId}) async {
    String resolvedNoteId = noteId ?? '';
    if (resolvedNoteId.isEmpty) {
      final newNote = await NoteProject.create(title: '');
      ref
          .read(noteProjectsProvider.notifier)
          .put(key: newNote.id, value: newNote);
      resolvedNoteId = newNote.id;
    }
    return routeState.go(AppRoutesName.getNotePath(noteId: resolvedNoteId));
  }

  /// ******************************
  ///         IDEAS
  /// ******************************

  void goCreateIdea() => routeState.go(AppRoutesName.createIdea);
  void goIdeaScreen({required final String ideaId}) =>
      routeState.go(AppRoutesName.getIdeaPath(ideaId: ideaId));

  Future<void> onCreateIdea(final String title) async {
    final idea = await IdeaProject.create(title: title);
    ref.read(ideaProjectsProvider.notifier).put(key: idea.id, value: idea);
    await routeState.go(AppRoutesName.getIdeaPath(ideaId: idea.id));
  }

  Future<void> onIdeaAnswerExpand(
    final IdeaProjectAnswer answer,
    final IdeaProject idea,
  ) async {
    await routeState.go(
      AppRoutesName.getIdeaAnswerPath(
        ideaId: idea.id,
        answerId: answer.id,
      ),
    );
  }

  Future<void> onUnknownIdeaAnswer(
    final String answerId,
    final IdeaProject idea,
  ) async {
    // TODO(arenukvern): add notification - answer with id not found
    /// or maybe better to suggest create IdeaAnswer too
    /// with that message
    goIdeaScreen(ideaId: idea.id);
  }

  /// ******************************
  ///         Handlers
  /// ******************************

  void onProjectTap(final BasicProject project) {
    if (project is IdeaProject) {
      goIdeaScreen(ideaId: project.id);
    } else if (project is NoteProject) {
      goNoteScreen(noteId: project.id);
    } else {
      throw UnimplementedError();
    }
  }
}
