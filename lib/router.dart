import 'package:flutter/cupertino.dart';
import 'package:lastanswer/app_scaffold.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/home_screen.dart';
import 'package:lastanswer/other/other.dart';

final appRouter = GoRouter(
  redirect: _handleRootRedirect,
  routes: [
    ShellRoute(
      builder: (final context, final router, final navigator) =>
          AppScaffold(navigator: navigator),
      routes: [
        AppRoute(AppPaths.bootstrap, (final _) => const LoadingScreen()),
        AppRoute(AppPaths.intro, (final _) => const IntroScreen()),
        AppRoute(AppPaths.home, (final _) => const HomeScreen()),
      ],
    ),
  ],
);

/// Custom GoRoute sub-class to make the router declaration easier to read
class AppRoute extends GoRoute {
  AppRoute(
    final String path,
    final Widget Function(GoRouterState s) builder, {
    final List<GoRoute> routes = const [],
    this.useFade = false,
  }) : super(
          path: path,
          routes: routes,
          pageBuilder: (final context, final state) {
            final pageContent = Scaffold(
              body: builder(state),
              resizeToAvoidBottomInset: false,
            );
            if (useFade) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: pageContent,
                transitionsBuilder: (
                  final context,
                  final animation,
                  final secondaryAnimation,
                  final child,
                ) =>
                    FadeTransition(opacity: animation, child: child),
              );
            }
            return CupertinoPage(child: pageContent);
          },
        );
  final bool useFade;
}

String? _handleRootRedirect(
  final BuildContext context,
  final GoRouterState state,
) {
  final appStatus = context.read<AppNotifier>().value.status;
  final location = state.uri.toString();
  // Prevent anyone from navigating away from `/` if app is starting up.
  if (appStatus == AppStatus.loading && location != AppPaths.bootstrap) {
    return AppPaths.bootstrap;
  }
  //  else if (location == AppPaths.bootstrap) {
  //   debugPrint('Router: hasCompletedOnboarding $hasCompletedOnboarding');

  //   /// at this moment user should be logged in
  //   if (hasCompletedOnboarding) {
  //     return AppPaths.home;
  //   } else {
  //     return AppPaths.intro;
  //   }
  // }
  debugPrint('Navigate to: ${state.uri}');
  return null; // do nothing
}
