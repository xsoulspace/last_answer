library app_navigator;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/providers/providers.dart';
import 'package:lastanswer/screens/home/home.dart';
import 'package:lastanswer/screens/idea_project/idea_project.dart';
import 'package:lastanswer/screens/info/app_info.dart';
import 'package:lastanswer/screens/note_project/note_project.dart';
import 'package:lastanswer/screens/settings/settings.dart';
import 'package:lastanswer/utils/utils.dart';

part 'app_navigator_controller.dart';
part 'app_routes.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class AppNavigator extends ConsumerStatefulWidget {
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

class _AppNavigatorState extends ConsumerState<AppNavigator> {
  final _homeKey = const ValueKey<String>('home');
  final _settingsKey = const ValueKey<String>('settings');
  final _infoKey = const ValueKey<String>('info');

  final _notesKey = const ValueKey<String>('notes');
  final _notesNoteKey = const ValueKey<String>('notes/note');

  final _createIdeaKey = const ValueKey<String>('createIdea');
  final _ideasKey = const ValueKey<String>('ideas');
  final _ideasIdeaKey = const ValueKey<String>('ideas/idea');
  final _ideasIdeaAnswerKey = const ValueKey<String>('ideas/idea/answer');
  final _largeScreenHomeNavigatorKey = GlobalKey();
  late final AppNavigatorController _navigatorController;
  RouteState get routeState => widget.routeState;

  @override
  void initState() {
    _navigatorController =
        AppNavigatorController.use(routeState: routeState, ref: ref);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final String? noteId = routeState.route.parameters['noteId'];
    final String? ideaId = routeState.route.parameters['ideaId'];
    final String? answerId = routeState.route.parameters['answerId'];
    final emptyPage = MaterialPage<void>(child: Container());
    Future<bool> _handleWillPop() async {
      switch (routeState.route.pathTemplate) {
        case AppRoutesName.ideaAnswer:
          _navigatorController.goIdeaScreen(ideaId: ideaId!);
          break;
        case AppRoutesName.idea:
        case AppRoutesName.note:
        case AppRoutesName.createIdea:
        case AppRoutesName.settings:
          _navigatorController.goHome();
          break;
        case AppRoutesName.home:
      }
      return false;
    }

    Widget willPopScope({required final Widget child}) {
      return WillPopScope(onWillPop: _handleWillPop, child: child);
    }

    Page appInfoPage() => MaterialPage(
          key: _infoKey,
          fullscreenDialog: true,
          child: willPopScope(
            child: AppInfoScreen(
              onBack: _navigatorController.goHome,
            ),
          ),
        );
    Page settingsPage() => MaterialPage<void>(
          key: _settingsKey,
          fullscreenDialog: true,
          child: willPopScope(
            child: SettingsScreen(
              onBack: _navigatorController.goHome,
            ),
          ),
        );

    Page notePage() => MaterialPage<void>(
          key: _ideasIdeaKey,
          restorationId: routeState.route.path,
          name: routeState.route.path,
          child: willPopScope(
            child: NoteProjectScreen(
              onBack: _navigatorController.goHome,
              noteId: noteId!,
              key: ValueKey(noteId),
            ),
          ),
        );
    Page ideaPage() => MaterialPage<void>(
          key: _ideasIdeaKey,
          restorationId: routeState.route.path,
          name: routeState.route.path,
          child: willPopScope(
            child: IdeaProjectScreen(
              onBack: _navigatorController.goHome,
              onAnswerExpand: _navigatorController.onIdeaAnswerExpand,
              ideaId: ideaId!,
              key: ValueKey(ideaId),
            ),
          ),
        );
    Page ideaAnswerPage() => MaterialPage<void>(
          fullscreenDialog: true,
          key: _ideasIdeaAnswerKey,
          restorationId: routeState.route.path,
          name: routeState.route.path,
          child: willPopScope(
            child: IdeaAnswerScreen(
              onUnknown: _navigatorController.onUnknownIdeaAnswer,
              onBack: (final idea) =>
                  _navigatorController.goIdeaScreen(ideaId: idea.id),
              answerId: answerId!,
              ideaId: ideaId!,
              key: ValueKey('$ideaId-$answerId'),
            ),
          ),
        );
    Page createIdeaPage() => MaterialPage<void>(
          key: _createIdeaKey,
          fullscreenDialog: true,
          child: willPopScope(
            child: CreateIdeaProjectScreen(
              onBack: _navigatorController.goHome,
              onCreate: _navigatorController.onCreateIdea,
            ),
          ),
        );

    List<Page> getLargeScreenPages() => [
          if (routeState.route.pathTemplate.startsWith(AppRoutesName.home)) ...[
            MaterialPage<void>(
              key: _homeKey,
              child: willPopScope(
                child: LargeHomeScreen(
                  onGoHome: _navigatorController.goHome,
                  onInfoTap: _navigatorController.goAppInfo,
                  onCreateIdeaTap: _navigatorController.goCreateIdea,
                  onCreateNoteTap: _navigatorController.goNoteScreen,
                  onProjectTap: _navigatorController.onProjectTap,
                  onSettingsTap: _navigatorController.goSettings,
                  mainScreenNavigator: Navigator(
                    key: _largeScreenHomeNavigatorKey,
                    onGenerateRoute: (final _) => null,
                    pages: [
                      if (routeState.route.pathTemplate == AppRoutesName.note)
                        notePage()
                      else if (routeState.route.pathTemplate
                          .contains(AppRoutesName.idea)) ...[
                        ideaPage(),
                      ] else if (routeState.route.pathTemplate ==
                          AppRoutesName.settings)
                        settingsPage()
                      else
                        emptyPage
                    ],
                    onPopPage: (final route, final result) =>
                        route.didPop(result),
                  ),
                ),
              ),
            ),
            if (routeState.route.pathTemplate == AppRoutesName.createIdea)
              createIdeaPage()
            else if (routeState.route.pathTemplate == AppRoutesName.ideaAnswer)
              ideaAnswerPage()
            else if (routeState.route.pathTemplate == AppRoutesName.appInfo)
              appInfoPage()
          ]
        ];

    List<Page> getSmallScreenPages() => [
          if (routeState.route.pathTemplate == AppRoutesName.home)
            MaterialPage<void>(
              key: _homeKey,
              child: willPopScope(
                child: SmallHomeScreen(
                  onInfoTap: _navigatorController.goAppInfo,
                  onCreateIdeaTap: _navigatorController.goCreateIdea,
                  onCreateNoteTap: _navigatorController.goNoteScreen,
                  onProjectTap: _navigatorController.onProjectTap,
                  onSettingsTap: _navigatorController.goSettings,
                  onGoHome: _navigatorController.goHome,
                ),
              ),
            )
          else if (routeState.route.pathTemplate == AppRoutesName.settings)
            settingsPage()
          else if (routeState.route.pathTemplate == AppRoutesName.appInfo)
            appInfoPage()
          else if (routeState.route.pathTemplate == AppRoutesName.createIdea)
            createIdeaPage()
          else if (routeState.route.pathTemplate == AppRoutesName.note)
            notePage()
          else if (routeState.route.pathTemplate
              .contains(AppRoutesName.idea)) ...[
            ideaPage(),
            if (routeState.route.pathTemplate == AppRoutesName.ideaAnswer)
              ideaAnswerPage()
          ] else
            emptyPage
        ];
    return ResponsiveNavigator(
      navigatorKey: widget.navigatorKey,
      onLargeScreen: getLargeScreenPages,
      onSmallScreen: getSmallScreenPages,
      onPopPage: (final route, final dynamic result) {
        /// ! here will go selected pages logic.
        final maybePage = route.settings;
        if (maybePage is Page) {
          if (maybePage.key == _createIdeaKey) {
            _navigatorController.goHome();
          } else if (maybePage.key == _ideasIdeaKey) {
            _navigatorController.goHome();
          } else if (maybePage.key == _ideasIdeaAnswerKey) {
            final arr = maybePage.name?.split('/') ?? [];
            if (arr.length == 4) {
              _navigatorController.goIdeaScreen(ideaId: arr[4]);
            } else {
              _navigatorController.goHome();
            }
          } else if (maybePage.key == _settingsKey) {
            _navigatorController.goHome();
          }
        }

        final popped = route.didPop(result);
        return popped;
      },
    );
  }
}
