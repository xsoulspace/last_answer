import 'package:la_core/la_core.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:provider/provider.dart';

class AuthGuard implements RouteGuard<ParsedRoute> {
  AuthGuard({
    required this.userNotifier,
  });
  final UserNotifier userNotifier;
  static final signInRoute =
      ParsedRoute.fromPathTemplate(NavigationRoutes.signUp);

  @override
  Future<ParsedRoute> redirect(final ParsedRoute from) async {
    if (userNotifier.authService.isAuthorized) {
      if (from.pathTemplate == NavigationRoutes.signUp ||
          from.pathTemplate == NavigationRoutes.signUp) {
        return ParsedRoute.fromPathTemplate(
          NavigationRoutes.getCompany(userNotifier.companyId),
        );
      }
      final routeParams = from.parameters;
      if (routeParams.containsKey('companyId')) {
        final companyId = int.tryParse(routeParams['companyId'] ?? '');

        if (companyId != null && userNotifier.companyId != companyId) {
          await userNotifier.switchCurrentAccountById(companyId);
          return from;
        }
      }
      return from;
    }
    if (from.pathTemplate == NavigationRoutes.signUp ||
        from.pathTemplate == NavigationRoutes.signUp) {
      return from;
    } else {
      return signInRoute;
    }
  }
}

List<RouteGuard<ParsedRoute>> useNavigationGuards(final Locator read) {
  return [AuthGuard(userNotifier: read<UserNotifier>())];
}
