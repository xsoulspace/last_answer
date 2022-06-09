import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigator/app_navigator_controller.dart';
import 'package:lastanswer/pack_app/navigator/route_parameters.dart';

class AppNavigatorDataProvider {
  AppNavigatorDataProvider({
    required final this.routeState,
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
