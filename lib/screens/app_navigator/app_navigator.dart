library app_navigator;

import 'package:flutter/material.dart';
import 'package:lastanswer/screens/home/home.dart';
import 'package:lastanswer/utils/utils.dart';

part 'app_routes.dart';

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
  final _homeKey = const ValueKey<String>('home');
  RouteState get routeState => widget.routeState;
  @override
  Widget build(final BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (final route, final dynamic result) {
        // ! here will go selected pages logic..
        // When a page that is stacked on top of the scaffold is popped, display
        // the /books or /authors tab in BookstoreScaffold.
        // if (route.settings is Page &&
        //     (route.settings as Page).key == bookDetailsKey) {
        //   routeState.go('/books/popular');
        // }

        // if (route.settings is Page &&
        //     (route.settings as Page).key == authorDetailsKey) {
        //   routeState.go('/authors');
        // }

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
              onCreateIdeaTap: () {},
              onProjectTap: (final _) {},
              onSettingsTap: () {},
            ),
          )
        else
          MaterialPage<void>(child: Container())
      ],
    );
  }
}
