part of pack_app;

@immutable
class AppNavigatorController {
  const AppNavigatorController.use({
    required this.routeState,
    required this.context,
    required this.screenLayout,
  });
  final RouteState routeState;
  final BuildContext context;
  final ScreenLayout screenLayout;

  void go(final AppRouteName routeName) => unawaited(routeState.go(routeName));
  void goHome() => go(AppRoutesName.home);
  void goBackFromSettings() {
    if (routeState.route.pathTemplate == AppRoutesName.settings ||
        screenLayout.notSmall) {
      goHome();
    } else {
      goSettings();
    }
  }

  void goSettings() => go(AppRoutesName.settings);

  void goAppInfo() => go(AppRoutesName.appInfo);

  Future<void> goNoteScreen({final String? noteId}) async {
    String resolvedNoteId = noteId ?? '';
    if (resolvedNoteId.isEmpty) {
      final folder = context.read<FolderStateProvider>();
      final settings = context.read<GeneralSettingsController>();
      final noteProjects = context.read<NoteProjectsProvider>();
      final currentFolder = folder.state;
      final newNote = await NoteProject.create(
        title: '',
        folder: currentFolder,
        charactersLimit: settings.charactersLimitForNewNotes,
      );
      currentFolder.addProject(newNote);
      noteProjects.put(key: newNote.id, value: newNote);
      folder.notify();
      resolvedNoteId = newNote.id;
    }

    return routeState.go(AppRoutesName.getNotePath(noteId: resolvedNoteId));
  }

  /// ******************************
  ///         IDEAS
  /// ******************************

  void goCreateIdea() => go(AppRoutesName.createIdea);
  void goIdeaScreen({required final String ideaId}) =>
      go(AppRoutesName.getIdeaPath(ideaId: ideaId));

  Future<void> onCreateIdea(final String title) async {
    final folder = context.read<FolderStateProvider>();
    final currentFolder = folder.state;
    final ideaProjectProvider = context.read<IdeaProjectsProvider>();
    final idea = await IdeaProject.create(
      title: title,
      folder: currentFolder,
    );
    currentFolder.addProject(idea);
    ideaProjectProvider.put(key: idea.id, value: idea);
    folder.notify();
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
  ) async =>
      goIdeaScreen(ideaId: idea.id);

  /// ******************************
  ///         Handlers
  /// ******************************

  void onProjectTap(final BasicProject project) {
    if (project is IdeaProject) {
      goIdeaScreen(ideaId: project.id);
    } else if (project is NoteProject) {
      unawaited(goNoteScreen(noteId: project.id));
    } else {
      throw UnimplementedError();
    }
  }
}
