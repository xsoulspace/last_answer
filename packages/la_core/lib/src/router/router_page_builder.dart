part of 'router.dart';

class RouterController {
  RouterController.use(final Locator read) : routeState = read<RouteState>();
  final RouteState routeState;

  void to(final String routeName) {
    unawaited(routeState.go(routeName));
  }
}

class _RouterDto<TRouterController extends RouterController> {
  _RouterDto.use(final Locator read)
      : routeState = read<RouteState>(),
        routerController = read<TRouterController>();
  final TRouterController routerController;
  final RouteState routeState;
  String get pathTemplate => routeState.route.pathTemplate;
}

class RouterPageBuilder<TRouterController extends RouterController> {
  RouterPageBuilder.use({
    required final Locator read,
  }) : _dto = _RouterDto<TRouterController>.use(read);
  final _RouterDto<TRouterController> _dto;

  TRouterController get routerController => _dto.routerController;
  RouteState get routeState => _dto.routeState;
  TRouteParams getParams<TRouteParams>(
    final FromJsonCallback<TRouteParams> paramsFromJson,
  ) =>
      paramsFromJson(routeState.route.parameters);
  String get pathTemplate => _dto.pathTemplate;
}
