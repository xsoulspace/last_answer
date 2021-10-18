library app_navigator;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/providers/providers.dart';
import 'package:lastanswer/screens/home/home.dart';
import 'package:lastanswer/screens/idea_project/idea_project.dart';
import 'package:lastanswer/screens/settings/settings.dart';
import 'package:lastanswer/utils/utils.dart';

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
  RouteState get routeState => widget.routeState;
  void goHome() => routeState.go(AppRoutesName.home);
  void goSettings() => routeState.go(AppRoutesName.settings);
  void goIdeaScreen({required final String ideaId}) =>
      routeState.go(AppRoutesName.getIdeaPath(ideaId: ideaId));
  @override
  Widget build(final BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (final route, final dynamic result) {
        /// ! here will go selected pages logic.
        final maybePage = route.settings;
        if (maybePage is Page) {
          if (maybePage.key == _createIdeaKey) {
            goHome();
          } else if (maybePage.key == _ideasIdeaKey) {
            goHome();
          } else if (maybePage.key == _ideasIdeaAnswerKey) {
            final arr = maybePage.name?.split('/') ?? [];
            if (arr.length == 4) {
              goIdeaScreen(ideaId: arr[4]);
            } else {
              goHome();
            }
          } else if (maybePage.key == _settingsKey) {
            goHome();
          }
        }

        final popped = route.didPop(result);
        return popped;
      },
      pages: [
        if (routeState.route.pathTemplate == AppRoutesName.home)
          // Display the sign in screen.
          MaterialPage<void>(
            key: _homeKey,
            child: HomeScreen(
              onInfoTap: () {},
              onCreateIdeaTap: () => routeState.go(AppRoutesName.createIdea),
              onCreateNoteTap: () {},
              onProjectTap: (final project) {
                if (project is IdeaProject) {
                  goIdeaScreen(ideaId: project.id);
                } else {
                  throw UnimplementedError();
                }
              },
              onSettingsTap: goSettings,
            ),
          )
        else if (routeState.route.pathTemplate == AppRoutesName.settings)
          // Display the sign in screen.
          MaterialPage<void>(
            key: _settingsKey,
            child: SettingsScreen(
              onBack: goHome,
            ),
          )
        else if (routeState.route.pathTemplate == AppRoutesName.createIdea)
          // Display the sign in screen.
          MaterialPage<void>(
            key: _createIdeaKey,
            fullscreenDialog: true,
            child: CreateIdeaProjectScreen(
              onBack: goHome,
              onCreate: (final ideaTitle) async {
                final idea = await IdeaProject.create(title: ideaTitle);
                ref
                    .read(ideaProjectsProvider.notifier)
                    .put(key: idea.id, value: idea);
                await routeState.go(AppRoutesName.getIdeaPath(ideaId: idea.id));
              },
            ),
          )
        else if (routeState.route.pathTemplate.contains(AppRoutesName.idea))
          // Display the sign in screen.
          ...[
          MaterialPage<void>(
            key: _ideasIdeaKey,
            restorationId: routeState.route.path,
            name: routeState.route.path,
            child: IdeaProjectScreen(
              onBack: goHome,
              onAnswerExpand: (final answer, final idea) async {
                await routeState.go(
                  AppRoutesName.getIdeaAnswerPath(
                    ideaId: idea.id,
                    answerId: answer.id,
                  ),
                );
              },
              ideaId: routeState.route.parameters['ideaId']!,
            ),
          ),
          if (routeState.route.pathTemplate == AppRoutesName.ideaAnswer)
            MaterialPage<void>(
              fullscreenDialog: true,
              key: _ideasIdeaAnswerKey,
              restorationId: routeState.route.path,
              name: routeState.route.path,
              child: IdeaAnswerScreen(
                onUnknown: (final answerId, final idea) {
                  // TODO(arenukvern): add notification - answer with id not found
                  /// or maybe better to suggest create IdeaAnswer too
                  /// with that message
                  goIdeaScreen(ideaId: idea.id);
                },
                onBack: (final idea) => goIdeaScreen(ideaId: idea.id),
                answerId: routeState.route.parameters['answerId']!,
                ideaId: routeState.route.parameters['ideaId']!,
              ),
            )
        ] else
          MaterialPage<void>(child: Container())
      ],
    );
  }
}
