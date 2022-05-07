part of pack_app;

class AppNavigatorPageBuilder {
  AppNavigatorPageBuilder({
    required final this.popper,
    required final this.context,
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

  Page appInfoPage() {
    return MaterialPage(
      key: NavigatorValueKeys._info,
      fullscreenDialog: true,
      child: AppNavigatorPopScope(
        popper: popper,
        child: AppInfoScreen(
          onBack: navigatorController.goHome,
        ),
      ),
    );
  }

  /// ********************************************
  /// *      SETTINGS START
  /// ********************************************

  Page settingsPage() {
    return FadedRailPage<void>(
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
  }

  /// ********************************************
  /// *      SETTINGS END
  /// ********************************************

  Page notePage() {
    return MaterialPage<void>(
      key: NavigatorValueKeys._notesNote,
      restorationId: routeState.route.path,
      fullscreenDialog: isNativeDesktop,
      name: routeState.route.path,
      child: AppNavigatorPopScope(
        popper: popper,
        child: NoteProjectScreen(
          checkIsProjectActive: checkIsProjectActive,
          onGoHome: popper.navigatorController.goHome,
          onBack: (final note) async {
            if (note.note.replaceAll(' ', '').isEmpty) {
              context.read<NoteProjectsProvider>().remove(key: note.id);
              note.folder?.removeProject(note);
              await note.delete();
            }
            navigatorController.goHome();
          },
          noteId: params.noteId!,
          key: ValueKey(params.noteId),
        ),
      ),
    );
  }

  Page ideaPage() {
    return MaterialPage<void>(
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
  }

  Page ideaAnswerPage() {
    return MaterialPage<void>(
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
  }

  Page createIdeaPage() {
    return MaterialPage<void>(
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

  Page signInPage() {
    return MaterialPage<void>(
      key: NavigatorValueKeys._signIn,
      fullscreenDialog: true,
      child: AppNavigatorPopScope(
        popper: popper,
        child: const SignInScreen(),
      ),
    );
  }
}
