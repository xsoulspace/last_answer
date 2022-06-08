import 'package:flutter/material.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigator/app_navigator.dart';
import 'package:lastanswer/pack_app/navigator/app_navigator_page_builder.dart';
import 'package:lastanswer/pack_app/navigator/app_navigator_pop_scope.dart';
import 'package:lastanswer/pack_app/navigator/app_navigator_popper.dart';
import 'package:lastanswer/pack_app/navigator/app_routes.dart';
import 'package:lastanswer/pack_app/screens/home/large_home_screen.dart';
import 'package:lastanswer/pack_app/screens/home/small_home_screen.dart';

class AppNavigatorLayoutBuilder {
  AppNavigatorLayoutBuilder({
    required final this.pageBuilder,
  }) : popper = pageBuilder.popper;
  final AppNavigatorPageBuilder pageBuilder;
  final AppNavigatorPopper popper;
  String get pathTemplate => popper.pathTemplate;

  List<Page> getLargeScreenPages() {
    return [
      if (pathTemplate.startsWith(AppRoutesName.home)) ...[
        MaterialPage<void>(
          key: NavigatorValueKeys.home,
          child: AppNavigatorPopScope(
            popper: popper,
            child: LargeHomeScreen(
              onFolderTap: pageBuilder.onChangeFolder,
              checkIsProjectActive: pageBuilder.checkIsProjectActive,
              onGoHome: popper.navigatorController.goHome,
              onInfoTap: popper.navigatorController.goAppInfo,
              onCreateIdeaTap: popper.navigatorController.goCreateIdea,
              onCreateNoteTap: popper.navigatorController.goNoteScreen,
              onProjectTap: popper.navigatorController.onProjectTap,
              onSettingsTap: popper.navigatorController.goSettings,
              mainScreenNavigator: Navigator(
                key: NavigatorValueKeys.largeScreenHomeNavigator,
                onGenerateRoute: (final _) => null,
                pages: [
                  if (pathTemplate == AppRoutesName.note)
                    pageBuilder.notePage()
                  else if (pathTemplate.contains(AppRoutesName.idea))
                    pageBuilder.ideaPage()
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
        else if (pathTemplate.startsWith(AppRoutesName.settings)) ...[
          pageBuilder.settingsPage(),
        ] else if (pathTemplate == AppRoutesName.appInfo)
          pageBuilder.appInfoPage(),
      ],
    ];
  }

  List<Page> getSmallScreenPages() {
    return [
      FadedRailPage<void>(
        key: NavigatorValueKeys.home,
        child: AppNavigatorPopScope(
          popper: popper,
          child: SmallHomeScreen(
            onFolderTap: pageBuilder.onChangeFolder,
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
      if (pathTemplate.startsWith(AppRoutesName.settings)) ...[
        pageBuilder.settingsPage(),
      ] else if (pathTemplate == AppRoutesName.appInfo)
        pageBuilder.appInfoPage()
      else if (pathTemplate == AppRoutesName.createIdea)
        pageBuilder.createIdeaPage()
      else if (pathTemplate == AppRoutesName.note)
        pageBuilder.notePage()
      else if (pathTemplate.contains(AppRoutesName.idea)) ...[
        pageBuilder.ideaPage(),
        if (pathTemplate == AppRoutesName.ideaAnswer)
          pageBuilder.ideaAnswerPage(),
      ]
    ];
  }
}
