part of pack_app;

class AppNavigatorDataProvider {
  AppNavigatorDataProvider({
    required final this.routeState,
    required final BuildContext context,
  })  : pathTemplate = routeState.route.pathTemplate,
        navigatorController = AppNavigatorController.use(
          routeState: routeState,
          context: context,
        ),
        params = AppRouteParameters.fromJson(routeState.route.parameters);
  final AppNavigatorController navigatorController;
  final RouteState routeState;
  final String pathTemplate;
  final AppRouteParameters params;
}
