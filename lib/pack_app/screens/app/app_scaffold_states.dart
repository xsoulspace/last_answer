part of 'app_scaffold.dart';

_ExternalProvidersScaffoldState _useExternalProvidersScaffoldState() => use(
      ContextfulLifeHook(
        debugLabel: 'useExternalProvidersScaffoldState',
        state: _ExternalProvidersScaffoldState(),
      ),
    );

class _ExternalProvidersScaffoldState extends ContextfulLifeState {
  _ExternalProvidersScaffoldState();
  late final RouteState routeState;
  late final TemplateRouteParser routeParser;
  @override
  void initState() {
    routeParser = TemplateRouteParser(
      allowedPaths: NavigationRoutes.routes,
      guards: [],
    );
    routeState = RouteState(routeParser);
    super.initState();
  }

  @override
  void dispose() {
    routeState.dispose();
    super.dispose();
  }
}

_AppScaffoldBodyState _useAppScaffoldBodyState(final Locator read) => use(
      ContextfulLifeHook(
        debugLabel: 'AppScaffoldBodyState',
        state: _AppScaffoldBodyState(
          routeState: read<RouteState>(),
        ),
      ),
    );

class _AppScaffoldBodyState extends ContextfulLifeState {
  _AppScaffoldBodyState({
    required this.routeState,
  });
  final RouteState routeState;
  late final SimpleRouterDelegate routerDelegate;
  final navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    routerDelegate = SimpleRouterDelegate(
      routeState: routeState,
      builder: (final context) => AppNavigator(
        navigatorKey: navigatorKey,
      ),
      navigatorKey: navigatorKey,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    routerDelegate.dispose();
  }
}
