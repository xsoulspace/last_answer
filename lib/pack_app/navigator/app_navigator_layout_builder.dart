part of pack_app;

class AppNavigatorLayoutBuilder {
  AppNavigatorLayoutBuilder({
    required this.pageBuilder,
  }) : popper = pageBuilder.popper;
  final AppNavigatorPageBuilder pageBuilder;
  final AppNavigatorPopper popper;
  String get pathTemplate => popper.pathTemplate;

  List<Page> getLargeScreenPages() => [
        if (pageBuilder.pathTemplate.startsWith(AppRoutesName.home)) ...[
          MaterialPage<void>(
            key: NavigatorValueKeys._home,
            child: AppNavigatorPopScope(
              popper: popper,
              child: LargeHomeScreen(
                checkIsProjectActive: pageBuilder.checkIsProjectActive,
                onGoHome: popper.navigatorController.goHome,
                onInfoTap: popper.navigatorController.goAppInfo,
                onCreateIdeaTap: popper.navigatorController.goCreateIdea,
                onCreateNoteTap: popper.navigatorController.goNoteScreen,
                onProjectTap: popper.navigatorController.onProjectTap,
                onSettingsTap: popper.navigatorController.goSettings,
                mainScreenNavigator: Navigator(
                  key: NavigatorValueKeys._largeScreenHomeNavigator,
                  onGenerateRoute: (final _) => null,
                  pages: [
                    if (pathTemplate == AppRoutesName.note)
                      pageBuilder.notePage()
                    else if (pathTemplate.contains(AppRoutesName.idea))
                      pageBuilder.ideaPage()
                    else
                      AppNavigatorPageBuilder.emptyPage,
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
          else if (pathTemplate.startsWith(AppRoutesName.settings))
            pageBuilder.settingsPage()
          else if (pathTemplate == AppRoutesName.appInfo)
            pageBuilder.appInfoPage(),
        ],
      ];

  List<Page> getSmallScreenPages() => [
        FadedRailPage<void>(
          key: NavigatorValueKeys._home,
          child: AppNavigatorPopScope(
            popper: popper,
            child: SmallHomeScreen(
              checkIsProjectActive: pageBuilder.checkIsProjectActive,
              onInfoTap: popper.navigatorController.goAppInfo,
              onCreateIdeaTap: popper.navigatorController.goCreateIdea,
              onCreateNoteTap: popper.navigatorController.goNoteScreen,
              onProjectTap: popper.navigatorController.onProjectTap,
              onSettingsTap: popper.navigatorController.goSettings,
              onGoHome: popper.navigatorController.goHome,
            ),
          ),
        ),
        if (pathTemplate.startsWith(AppRoutesName.settings))
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
        ],
      ];
}