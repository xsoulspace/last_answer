import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_app/widgets/widgets.dart';

/// !In case of new routes all routes should be added to values!
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
  redirect: _handleRedirect,
  routes: [
    ShellRoute(
      builder: (final context, final router, final navigator) =>
          AppScaffold(navigator: navigator),
      routes: [
        AppRoute(
          AppPaths.bootstrap,
          (final _) => const AppLoadingScreen(),
        ), // This will be hidden
        AppRoute(AppPaths.home, (final _) => HomeScreen()),
        AppRoute(AppPaths.intro, (final _) => IntroScreen()),
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

String? _handleRedirect(final BuildContext context, final GoRouterState state) {
  final appStatus = context.read<AppNotifier>().value.status;
  // Prevent anyone from navigating away from `/` if app is starting up.
  if (appStatus == AppStatus.loading ||
      state.uri.toString() != AppPaths.bootstrap) {
    return AppPaths.bootstrap;
  }
  debugPrint('Navigate to: ${state.uri}');
  return null; // do nothing
}
