part of utils;

/// The current route state. To change the current route, call obtain the state
/// using `RouteStateScope.of(context)` and call `go()`:
///
/// ```
/// RouteStateScope.of(context).go('/book/2');
/// ```
class RouteState extends ChangeNotifier {
  RouteState(this.parser) : _route = parser.initialRoute;
  TemplateRouteParser parser;
  ParsedRoute _route;

  ParsedRoute get route => _route;

  set route(final ParsedRoute route) {
    // Don't notify listeners if the path hasn't changed.
    if (_route == route) return;

    _route = route;
    notifyListeners();
  }

  Future<void> go(final String route) async {
    this.route =
        await parser.parseRouteInformation(RouteInformation(location: route));
  }
}

/// Provides the current [RouteState] to descendent widgets in the tree.
class RouteStateScope extends InheritedNotifier<RouteState> {
  const RouteStateScope({
    required final RouteState notifier,
    required final Widget child,
    final Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static RouteState of(final BuildContext context) {
    final state =
        context.dependOnInheritedWidgetOfExactType<RouteStateScope>()?.notifier;
    if (state == null) throw ArgumentError.notNull('RouteState');

    return state;
  }
}
