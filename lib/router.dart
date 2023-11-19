import 'package:flutter/cupertino.dart';
import 'package:lastanswer/app_scaffold.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/home_screen.dart';
import 'package:lastanswer/other/other.dart';

class AppPaths {
  AppPaths._();
  static const bootstrap = '/';
  static const home = '/home';
  static const intro = '/intro';
  static const createIdea = '/i/create';
  static const ideas = '/i';
  static const idea = '$ideas/:ideaId';
  static String getIdeaPath({required final String ideaId}) => '$ideas/$ideaId';
  static const ideaAnswer = '$ideas/:ideaId/:answerId';
  static String getIdeaAnswerPath({
    required final String ideaId,
    required final String answerId,
  }) =>
      '$ideas/$ideaId/$answerId';
  static const notes = '/n';
  static const note = '$notes/:noteId';
  static String getNotePath({required final String noteId}) => '$notes/$noteId';
  static const settings = '/settings';
  static const generalSettings = '$settings/general';
  static const profile = '$settings/profile';
  static const subscription = '$settings/subscription';
  static const changelog = '$settings/changelog';
  static const appInfo = '/info';
}

final appRouter = GoRouter(
  redirect: _handleRootRedirect,
  routes: [
    ShellRoute(
      builder: (final context, final router, final navigator) =>
          AppScaffold(navigator: navigator),
      routes: [
        AppRoute(
          AppPaths.bootstrap,
          (final _) => const LoadingScreen(),
        ), // This will be hidden
        AppRoute(AppPaths.home, (final _) => const HomeScreen()),
        AppRoute(AppPaths.intro, (final _) => const IntroScreen()),
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
  final hasCompletedOnboarding =
      context.read<UserNotifier>().hasCompletedOnboarding;
  final location = state.uri.toString();
  // Prevent anyone from navigating away from `/` if app is starting up.
  if (appStatus == AppStatus.loading || location != AppPaths.bootstrap) {
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
