part of pack_app;

class AppNavigatorPageBuilder {
  AppNavigatorPageBuilder({
    required this.popper,
    required this.context,
  });
  final AppNavigatorPopper popper;
  final BuildContext context;
  static final emptyPage = MaterialPage<void>(child: Container());

  AppNavigatorController get navigatorController => popper.navigatorController;
  RouteState get routeState => popper.routeState;
  AppRouteParameters get params => popper.params;
  String get pathTemplate => popper.pathTemplate;
  bool checkIsProjectActive(final BasicProject project) {
    if (project.id == params.noteId) return true;
    if (project.id == params.ideaId) return true;

    return false;
  }

  Page appInfoPage() => MaterialPage(
        key: NavigatorValueKeys._info,
        fullscreenDialog: true,
        child: AppNavigatorPopScope(
          popper: popper,
          child: AppInfoScreen(
            onBack: navigatorController.goHome,
          ),
        ),
      );

  /// ********************************************
  /// *      SETTINGS START
  /// ********************************************

  Page settingsPage() => FadedRailPage<void>(
        key: NavigatorValueKeys._settings,
        fullscreenDialog: true,
        child: AppNavigatorPopScope(
          popper: popper,
          child: SettingsScreen(
            onSelectRoute: navigatorController.go,
            onBack: navigatorController.goBackFromSettings,
          ),
        ),
      );

  /// ********************************************
  /// *      SETTINGS END
  /// ********************************************

  Page notePage() => MaterialPage<void>(
        key: NavigatorValueKeys._notesNote,
        restorationId: routeState.route.path,
        fullscreenDialog: isNativeDesktop,
        name: routeState.route.path,
        child: AppNavigatorPopScope(
          popper: popper,
          child: NoteProjectScreen(
            delegate: NoteProjectViewDelegate(
              noteId: params.noteId!,
              onBack: (){
                if (note.note.replaceAll(' ', '').isEmpty) {
                context.read<NoteProjectsState>().remove(key: note.id);
                note.folder?.removeProject(note);
                await note.delete();
              }
              navigatorController.goHome();
              },
              onGoHome: popper.navigatorController.goHome,
              checkIsProjectActive: checkIsProjectActive,
            ),
            key: ValueKey(params.noteId),
          ),
        ),
      );

  Page ideaPage() => MaterialPage<void>(
        key: NavigatorValueKeys._ideasIdea,
        fullscreenDialog: isNativeDesktop,
        restorationId: routeState.route.path,
        name: routeState.route.path,
        child: AppNavigatorPopScope(
          popper: popper,
          child: IdeaProjectScreen(
            onBack: navigatorController.goHome,
            onAnswerExpand: navigatorController.onIdeaAnswerExpand,
            ideaId: params.ideaId!,
            key: ValueKey(params.ideaId),
          ),
        ),
      );

  Page ideaAnswerPage() => MaterialPage<void>(
        fullscreenDialog: true,
        key: NavigatorValueKeys._ideasIdeaAnswer,
        restorationId: routeState.route.path,
        name: routeState.route.path,
        child: AppNavigatorPopScope(
          popper: popper,
          child: IdeaAnswerScreen(
            onUnknown: navigatorController.onUnknownIdeaAnswer,
            onBack: (final idea) =>
                navigatorController.goIdeaScreen(ideaId: idea.id),
            answerId: params.answerId!,
            ideaId: params.ideaId!,
            key: ValueKey('${params.ideaId}-${params.answerId}'),
          ),
        ),
      );

  Page createIdeaPage() => MaterialPage<void>(
        key: NavigatorValueKeys._createIdea,
        fullscreenDialog: true,
        child: AppNavigatorPopScope(
          popper: popper,
          child: CreateIdeaProjectScreen(
            onBack: navigatorController.goHome,
            onCreate: navigatorController.onCreateIdea,
          ),
        ),
      );
}
