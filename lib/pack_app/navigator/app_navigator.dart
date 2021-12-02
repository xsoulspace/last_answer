part of pack_app;

class _ValueKeys {
  _ValueKeys._();
  static const _home = ValueKey<String>('home');
  static const _settings = ValueKey<String>('settings');
  static const _info = ValueKey<String>('info');
  static const _notes = ValueKey<String>('notes');
  static const _notesNote = ValueKey<String>('notes/note');
  static const _createIdea = ValueKey<String>('createIdea');
  static const _ideas = ValueKey<String>('ideas');
  static const _ideasIdea = ValueKey<String>('ideas/idea');
  static const _ideasIdeaAnswer = ValueKey<String>('ideas/idea/answer');
  static final _largeScreenHomeNavigator = GlobalKey();
}

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class AppNavigator extends StatefulWidget {
  const AppNavigator({
    required final this.navigatorKey,
    required final this.routeState,
    final Key? key,
  }) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  final RouteState routeState;
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  static final emptyPage = MaterialPage<void>(child: Container());

  RouteState get routeState => widget.routeState;
  String get pathTemplate => routeState.route.pathTemplate;

  @override
  Widget build(final BuildContext context) {
    final popper = AppNavigatorPopper(routeState: routeState);
    final pageBuilder = AppNavigatorPageBuilder(popper: popper);
    final String? noteId = popper.params.noteId;
    final String? ideaId = popper.params.ideaId;

    bool checkIsProjectActive(final BasicProject project) {
      if (project.id == noteId) return true;
      if (project.id == ideaId) return true;
      return false;
    }

    List<Page> getLargeScreenPages() {
      return [
        if (pathTemplate.startsWith(AppRoutesName.home)) ...[
          MaterialPage<void>(
            key: _ValueKeys._home,
            child: AppNavigatorPopScope(
              popper: popper,
              child: LargeHomeScreen(
                checkIsProjectActive: checkIsProjectActive,
                onGoHome: popper.navigatorController.goHome,
                onInfoTap: popper.navigatorController.goAppInfo,
                onCreateIdeaTap: popper.navigatorController.goCreateIdea,
                onCreateNoteTap: popper.navigatorController.goNoteScreen,
                onProjectTap: popper.navigatorController.onProjectTap,
                onSettingsTap: popper.navigatorController.goSettings,
                mainScreenNavigator: Navigator(
                  key: _ValueKeys._largeScreenHomeNavigator,
                  onGenerateRoute: (final _) => null,
                  pages: [
                    if (pathTemplate == AppRoutesName.note)
                      pageBuilder.notePage()
                    else if (pathTemplate.contains(AppRoutesName.idea)) ...[
                      pageBuilder.ideaPage(),
                    ] else if (routeState.route.pathTemplate ==
                        AppRoutesName.settings)
                      pageBuilder.settingsPage()
                    else
                      emptyPage
                  ],
                  onPopPage: (final route, final result) =>
                      route.didPop(result),
                ),
              ),
            ),
          ),
          if (pathTemplate == AppRoutesName.createIdea)
            pageBuilder.createIdeaPage()
          else if (pathTemplate == AppRoutesName.ideaAnswer)
            pageBuilder.ideaAnswerPage()
          else if (pathTemplate == AppRoutesName.appInfo)
            pageBuilder.appInfoPage()
        ]
      ];
    }

    List<Page> getSmallScreenPages() {
      return [
        if (pathTemplate == AppRoutesName.home)
          MaterialPage<void>(
            key: _ValueKeys._home,
            child: AppNavigatorPopScope(
              popper: popper,
              child: SmallHomeScreen(
                checkIsProjectActive: checkIsProjectActive,
                onInfoTap: popper.navigatorController.goAppInfo,
                onCreateIdeaTap: popper.navigatorController.goCreateIdea,
                onCreateNoteTap: popper.navigatorController.goNoteScreen,
                onProjectTap: popper.navigatorController.onProjectTap,
                onSettingsTap: popper.navigatorController.goSettings,
                onGoHome: popper.navigatorController.goHome,
              ),
            ),
          )
        else if (pathTemplate == AppRoutesName.settings)
          pageBuilder.settingsPage()
        else if (pathTemplate == AppRoutesName.appInfo)
          pageBuilder.appInfoPage()
        else if (pathTemplate == AppRoutesName.createIdea)
          pageBuilder.createIdeaPage()
        else if (pathTemplate == AppRoutesName.note)
          pageBuilder.notePage()
        else if (pathTemplate.contains(AppRoutesName.idea)) ...[
          pageBuilder.ideaPage(),
          if (pathTemplate == AppRoutesName.ideaAnswer)
            pageBuilder.ideaAnswerPage()
        ] else
          emptyPage
      ];
    }

    return ResponsiveNavigator(
      navigatorKey: widget.navigatorKey,
      onLargeScreen: getLargeScreenPages,
      onSmallScreen: getSmallScreenPages,
      onPopPage: popper.onPopPage,
    );
  }
}
