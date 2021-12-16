part of pack_app;

class AppNavigatorLayoutBuilder {
  AppNavigatorLayoutBuilder({
    required final this.pageBuilder,
  }) : popper = pageBuilder.popper;
  final AppNavigatorPageBuilder pageBuilder;
  final AppNavigatorPopper popper;
  String get pathTemplate => popper.pathTemplate;
  bool checkIsProjectActive(final BasicProject project) {
    if (project.id == pageBuilder.params.noteId) return true;
    if (project.id == pageBuilder.params.ideaId) return true;

    return false;
  }

  List<Page> getLargeScreenPages() {
    return [
      if (pageBuilder.pathTemplate.startsWith(AppRoutesName.home)) ...[
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
                  ] else if (pathTemplate == AppRoutesName.settings)
                    pageBuilder.settingsPage()
                  else
                    AppNavigatorPageBuilder.emptyPage,
                ],
                onPopPage: (final route, final result) => route.didPop(result),
              ),
            ),
          ),
        ),
        if (pathTemplate == AppRoutesName.createIdea)
          pageBuilder.createIdeaPage()
        else if (pathTemplate == AppRoutesName.ideaAnswer)
          pageBuilder.ideaAnswerPage()
        else if (pathTemplate == AppRoutesName.appInfo)
          pageBuilder.appInfoPage(),
      ],
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
          pageBuilder.ideaAnswerPage(),
      ] else
        AppNavigatorPageBuilder.emptyPage,
    ];
  }
}
