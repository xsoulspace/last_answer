part of pack_app;

class AppNavigatorDataProvider {
  AppNavigatorDataProvider({
    required this.routeState,
    required final BuildContext context,
    required final ScreenLayout screenLayout,
  })  : pathTemplate = routeState.route.pathTemplate,
        navigatorController = AppNavigatorController.use(
          routeState: routeState,
          context: context,
          screenLayout: screenLayout,
        ),
        params = AppRouteParameters.fromJson(routeState.route.parameters);
  final AppNavigatorController navigatorController;
  final RouteState routeState;
  final String pathTemplate;
  final AppRouteParameters params;
}
