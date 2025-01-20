import 'package:go_router/go_router.dart';

extension GoRouterExtension on GoRouter {
  /// https://github.com/flutter/flutter/issues/129833
  String location() {
    final RouteMatchBase? lastMatch =
        routerDelegate.currentConfiguration.matches.lastOrNull;
    final RouteMatchList matchList;
    if (lastMatch != null && lastMatch is ImperativeRouteMatch) {
      matchList = lastMatch.matches;
    } else {
      matchList = routerDelegate.currentConfiguration;
    }
    final String location = matchList.uri.toString();
    return location;
  }
}
