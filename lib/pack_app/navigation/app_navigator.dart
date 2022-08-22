import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
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

    final keys = useState(AppPageBuilderKeys());
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

class AppPageBuilderKeys {
  final signIn = const ValueKey('Sign in');
  final signUp = const ValueKey('Sign up');
  final home = const ValueKey('home');
}

class AppPageBuilder extends RouterPageBuilder<AppRouterController> {
  AppPageBuilder.use({
    required this.keys,
    required final super.read,
  }) : super.use();
  static final emptyPage = NavigatorPage(
    child: const EmptyScreen(),
    key: const ValueKey('loading-screen'),
  );

  final AppPageBuilderKeys keys;

  Page home() => NavigatorPage(
        child: const DashboardScreen(),
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
  AppLayoutBuilder({required final super.pageBuilder});
  @override
  List<Page> buildPages() {
    final pages = <Page>[
      AppPageBuilder.emptyPage,
      pageBuilder.home(),
    ];
    if (pathTemplate == NavigationRoutes.signUp) {
      pages.add(pageBuilder.signIn());
    } else if (pathTemplate == NavigationRoutes.signUp) {
      pages.add(pageBuilder.signUp());
    }
    return pages;
  }
}
