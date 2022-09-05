import 'package:la_core/la_core.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';

class AppRouterController extends RouterController {
  AppRouterController.use(super.read) : super.use();

  void toHome() => NavigationRoutes.home;
  void toSignIn() => to(NavigationRoutes.signIn);
  void toSignUp() => to(NavigationRoutes.signUp);
}
