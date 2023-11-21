import 'package:flutter/cupertino.dart';
import 'package:lastanswer/app_scaffold.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/home_screen.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/other/other.dart';
import 'package:lastanswer/settings/pack_settings.dart';

final appRouter = GoRouter(
  redirect: _handleRootRedirect,
  routes: [
    ShellRoute(
      builder: (final context, final router, final navigator) =>
          AppScaffold(navigator: navigator),
      routes: [
        AppRoute(
          ScreenPaths.bootstrap,
          (final _) => const LoadingScreen(),
        ),
        AppRoute(
          ScreenPaths.intro,
          (final _) => const IntroScreen(),
        ),
        ShellRoute(
          builder: (final context, final state, final navigator) =>
              ScreenScaffold(
            navigator: HomeScreen(
              navigator: navigator,
            ),
          ),
          routes: [
            AppRoute(
              ScreenPaths.home,
              (final _) => const ProjectsListScreen(),
            ),
            AppRoute(
              '/home/n/:noteId',
              (final _) => const ProjectView(),
            ),
            AppRoute(
              '/home/i/:ideaId',
              (final _) => const ProjectView(),
            ),
          ],
        ),
        AppRoute(
          ScreenPaths.settings,
          (final _) => const SettingsScreen(),
        ),
        AppRoute(
          ScreenPaths.appInfo,
          (final _) => const AppInfoScreen(),
        ),
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
  if (appStatus == AppStatus.loading && location != ScreenPaths.bootstrap) {
    return ScreenPaths.bootstrap;
  }

  debugPrint('Navigate to: ${state.uri}');
  return null; // do nothing
}
