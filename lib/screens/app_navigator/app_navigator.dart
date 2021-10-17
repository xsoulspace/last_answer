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
  RouteState get routeState => widget.routeState;
  void geHome() => routeState.go(AppRoutesName.home);
  void openIdeaScreen({required final IdeaProject idea}) =>
      routeState.go(AppRoutesName.getIdeaPath(ideaId: idea.id));
  @override
  Widget build(final BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (final route, final dynamic result) {
        /// ! here will go selected pages logic..
        ///
        /// This is an example of selected pages logic:
        ///
        /// When a page that is stacked on top of the scaffold is popped,
        /// display the /books or /authors tab in BookstoreScaffold.
        /// if (route.settings is Page &&
        ///     (route.settings as Page).key == bookDetailsKey) {
        ///   routeState.go('/books/popular');
        /// }
        /// if (route.settings is Page &&
        ///     (route.settings as Page).key == authorDetailsKey) {
        ///   routeState.go('/authors');
        /// }

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
                  openIdeaScreen(idea: project);
                } else {
                  throw UnimplementedError();
                }
              },
              onSettingsTap: () => routeState.go(AppRoutesName.settings),
            ),
          )
        else if (routeState.route.pathTemplate == AppRoutesName.settings)
          // Display the sign in screen.
          MaterialPage<void>(
            key: _settingsKey,
            child: SettingsScreen(
              onBack: geHome,
            ),
          )
        else if (routeState.route.pathTemplate == AppRoutesName.createIdea)
          // Display the sign in screen.
          MaterialPage<void>(
            key: _settingsKey,
            child: CreateIdeaProjectScreen(
              onBack: geHome,
              onCreate: (final ideaTitle) async {
                final idea = await IdeaProject.create(title: ideaTitle);
                ref
                    .read(ideaProjectsProvider.notifier)
                    .put(key: idea.id, value: idea);
                await routeState.go(AppRoutesName.getIdeaPath(ideaId: idea.id));
              },
            ),
          )
        else if (routeState.route.pathTemplate == AppRoutesName.idea)
          // Display the sign in screen.
          MaterialPage<void>(
            key: _settingsKey,
            child: IdeaProjectScreen(
              onBack: geHome,
              projectId: routeState.route.parameters['id']!,
            ),
          )
        else
          MaterialPage<void>(child: Container())
      ],
    );
  }
}
