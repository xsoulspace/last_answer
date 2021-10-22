part of app_navigator;

class AppNavigatorController {
  AppNavigatorController.use({
    required final this.routeState,
    required final this.ref,
  });
  final RouteState routeState;
  final WidgetRef ref;
  void goHome() => routeState.go(AppRoutesName.home);
  void goSettings() => routeState.go(AppRoutesName.settings);
  void goCreateIdea() => routeState.go(AppRoutesName.createIdea);
  void goIdeaScreen({required final String ideaId}) =>
      routeState.go(AppRoutesName.getIdeaPath(ideaId: ideaId));

  Future<void> onCreateIdea(final String title) async {
    final idea = await IdeaProject.create(title: title);
    ref.read(ideaProjectsProvider.notifier).put(key: idea.id, value: idea);
    await routeState.go(AppRoutesName.getIdeaPath(ideaId: idea.id));
  }

  void onProjectTap(final BasicProject project) {
    if (project is IdeaProject) {
      goIdeaScreen(ideaId: project.id);
    } else if (project is NoteProject) {
      goNoteScreen(noteId: project.id);
    } else {
      throw UnimplementedError();
    }
  }

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
}
