part of 'router.dart';

class SimpleRouterDelegate extends RouterDelegate<ParsedRoute>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ParsedRoute> {
  SimpleRouterDelegate({
    required final this.routeState,
    required final this.builder,
    required final this.navigatorKey,
  }) {
    routeState.addListener(notifyListeners);
  }
  final RouteState routeState;
  final WidgetBuilder builder;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(final BuildContext context) => builder(context);

  @override
  Future<void> setNewRoutePath(final ParsedRoute configuration) async {
    routeState.route = configuration;
    return SynchronousFuture(null);
  }

  @override
  ParsedRoute get currentConfiguration => routeState.route;

  @override
  void dispose() {
    routeState
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
