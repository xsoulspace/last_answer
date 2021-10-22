library app_navigator;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/providers/providers.dart';
import 'package:lastanswer/screens/home/home.dart';
import 'package:lastanswer/screens/idea_project/idea_project.dart';
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
  final _notesKey = const ValueKey<String>('notes');
  final _notesNoteKey = const ValueKey<String>('notes/note');
  final _createIdeaKey = const ValueKey<String>('createIdea');
  final _ideasKey = const ValueKey<String>('ideas');
  final _ideasIdeaKey = const ValueKey<String>('ideas/idea');
  final _ideasIdeaAnswerKey = const ValueKey<String>('ideas/idea/answer');

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

    final largeScreenPages = [
      if (routeState.route.pathTemplate == AppRoutesName.home)
        MaterialPage<void>(
          key: _homeKey,
          child: willPopScope(
            child: HomeScreen(
              onInfoTap: () {},
              onCreateIdeaTap: _navigatorController.goCreateIdea,
              onCreateNoteTap: _navigatorController.goNoteScreen,
              onProjectTap: _navigatorController.onProjectTap,
              onSettingsTap: _navigatorController.goSettings,
            ),
          ),
        )
      else if (routeState.route.pathTemplate == AppRoutesName.settings)
        MaterialPage<void>(
          key: _settingsKey,
          child: willPopScope(
            child: SettingsScreen(
              onBack: _navigatorController.goHome,
            ),
          ),
        )
      else if (routeState.route.pathTemplate == AppRoutesName.createIdea)
        MaterialPage<void>(
          key: _createIdeaKey,
          fullscreenDialog: true,
          child: willPopScope(
            child: CreateIdeaProjectScreen(
              onBack: _navigatorController.goHome,
              onCreate: _navigatorController.onCreateIdea,
            ),
          ),
        )
      else if (routeState.route.pathTemplate == AppRoutesName.note)
        MaterialPage<void>(
          key: _ideasIdeaKey,
          restorationId: routeState.route.path,
          name: routeState.route.path,
          child: willPopScope(
            child: NoteProjectScreen(
              onBack: _navigatorController.goHome,
              noteId: noteId!,
            ),
          ),
        )
      else if (routeState.route.pathTemplate.contains(AppRoutesName.idea)) ...[
        MaterialPage<void>(
          key: _ideasIdeaKey,
          restorationId: routeState.route.path,
          name: routeState.route.path,
          child: willPopScope(
            child: IdeaProjectScreen(
              onBack: _navigatorController.goHome,
              onAnswerExpand: (final answer, final idea) async {
                await routeState.go(
                  AppRoutesName.getIdeaAnswerPath(
                    ideaId: idea.id,
                    answerId: answer.id,
                  ),
                );
              },
              ideaId: ideaId!,
            ),
          ),
        ),
        if (routeState.route.pathTemplate == AppRoutesName.ideaAnswer)
          MaterialPage<void>(
            fullscreenDialog: true,
            key: _ideasIdeaAnswerKey,
            restorationId: routeState.route.path,
            name: routeState.route.path,
            child: willPopScope(
              child: IdeaAnswerScreen(
                onUnknown: (final answerId, final idea) {
                  // TODO(arenukvern): add notification - answer with id not found
                  /// or maybe better to suggest create IdeaAnswer too
                  /// with that message
                  _navigatorController.goIdeaScreen(ideaId: idea.id);
                },
                onBack: (final idea) =>
                    _navigatorController.goIdeaScreen(ideaId: idea.id),
                answerId: answerId!,
                ideaId: ideaId,
              ),
            ),
          )
      ] else
        MaterialPage<void>(child: Container())
    ];
    return ResponsiveNavigator(
      navigatorKey: widget.navigatorKey,
      largeScreen: largeScreenPages,
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
