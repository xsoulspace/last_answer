import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:la_design_core/la_design_core.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_app/screens/home/home_layout_screen.dart';
import 'package:provider/provider.dart';

class AppNavigator extends HookWidget {
  const AppNavigator({
    required this.navigatorKey,
    final Key? key,
  }) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  Widget build(final BuildContext context) {
    context.watch<RouteState>();

    final keys = useState(const AppPageBuilderKeys());
    final pageBuilder =
        AppPageBuilder.use(keys: keys.value, read: context.read);
    final layoutBuilder = AppLayoutBuilder(pageBuilder: pageBuilder);

    return Navigator(
      key: navigatorKey,
      onPopPage: const RouterPopper().onPopPage,
      pages: layoutBuilder.buildPages(),
    );
  }
}

@immutable
class AppPageBuilderKeys {
  const AppPageBuilderKeys();
  ValueKey get signIn => const ValueKey('Sign in');
  ValueKey get signUp => const ValueKey('Sign up');
  ValueKey get home => const ValueKey('home');
}

class AppPageBuilder extends RouterPageBuilder<AppRouterController> {
  AppPageBuilder.use({
    required this.keys,
    required super.read,
  }) : super.use();
  static final emptyPage = NavigatorPage(
    child: const EmptyScreen(),
    key: const ValueKey('loading-screen'),
  );

  final AppPageBuilderKeys keys;

  Page home() => NavigatorPage(
        child: const HomeLayoutScreen(),
        key: keys.home,
      );
  Page signIn() => NavigatorPage(
        child: const SignInScreen(),
        key: keys.signIn,
      );
  Page signUp() => NavigatorPage(
        child: const SignUpScreen(),
        key: keys.signUp,
      );
}

class AppLayoutBuilder
    extends RouterLayoutBuilder<AppRouterController, AppPageBuilder> {
  AppLayoutBuilder({required super.pageBuilder});
  @override
  List<Page> buildPages() {
    final pages = <Page>[
      AppPageBuilder.emptyPage,
      pageBuilder.home(),
    ];
    if (pathTemplate == NavigationRoutes.signIn) {
      pages.add(pageBuilder.signIn());
    } else if (pathTemplate == NavigationRoutes.signUp) {
      pages.add(pageBuilder.signUp());
    }
    return pages;
  }
}
