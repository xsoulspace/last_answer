import 'package:la_core/la_core.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';

class AppRouterController extends RouterController {
  AppRouterController.use(super.read) : super.use();

  void toHome() => NavigationRoutes.home;
  void toSignIn() => to(
        NavigationRoutes.signUp,
      );
  void toSignUp() => to(
        NavigationRoutes.signUp,
        query: routeQuery?.toJson() as Map<String, String>?,
      );
  void toTimeTracker(final CompanyModelId companyId) =>
      to(NavigationRoutes.getTimeTracker(companyId));
  void toProjects(final CompanyModelId companyId) =>
      to(NavigationRoutes.getProjects(companyId));
  void toCompanyMembers(final CompanyModelId companyId) =>
      to(NavigationRoutes.getCompanyMembers(companyId));
}
