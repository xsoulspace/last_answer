import 'package:flutter/cupertino.dart';
import 'package:lastanswer/app_scaffold.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/home_screen.dart';
import 'package:lastanswer/home/project_route.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/other/other.dart';
import 'package:lastanswer/ui_pay/paywall_flow.dart';
import 'package:lastanswer/ui_pay/paywall_screen.dart';
import 'package:lastanswer/workbench/workbench_screen.dart';

final appRouter = GoRouter(
  redirect: _handleRootRedirect,
  routes: [
    ShellRoute(
      builder: (final context, final router, final navigator) =>
          AppScaffold(navigator: navigator),
      routes: [
        AppRoute(ScreenPaths.bootstrap, (final _) => const LoadingScreen()),
        AppRoute(ScreenPaths.intro, (final _) => const IntroScreen()),
        ShellRoute(
          builder: (final context, final state, final navigator) =>
              ScreenScaffold(navigator: HomeScreen(navigator: navigator)),
          routes: [
            AppRoute(
              ScreenPaths.home,
              (final _) => Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Builder(
                      builder: (context) => TextButton(
                        key: const ValueKey('home-open-workbench'),
                        onPressed: () => context.push('/home/workbench'),
                        child: const Text('Workbench'),
                      ),
                    ),
                  ),
                  const Expanded(child: ProjectsListScreen()),
                ],
              ),
            ),
            AppRoute(
              '/home/workbench',
              (final state) => WorkbenchScreen(
                project: state.uri.queryParameters['project'],
                collaboration: true,
              ),
            ),
            AppRoute(
              '/home/n/:noteId',
              (final state) => ProjectRoute(
                projectId: state.pathParameters['noteId']!,
                projectType: ProjectTypes.note,
                builder: (_, project) => ProjectView(project: project),
              ),
            ),
            AppRoute(
              '/home/d/:docId',
              (final state) => ProjectRoute(
                projectId: state.pathParameters['docId']!,
                projectType: ProjectTypes.doc,
                builder: (_, project) => ProjectView(project: project),
              ),
            ),
            AppRoute(
              '/home/i/:ideaId',
              (final state) => ProjectRoute(
                projectId: state.pathParameters['ideaId']!,
                projectType: ProjectTypes.idea,
                builder: (_, project) => ProjectView(project: project),
              ),
            ),
            AppRoute(ScreenPaths.changelog, (final _) => const ProjectView()),
            AppRoute(
              PaywallFlow.paywallPath,
              (final _) => const PaywallScreen(),
            ),
          ],
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
               transitionsBuilder:
                   (
                     final context,
                     final animation,
                     final secondaryAnimation,
                     final child,
                   ) => FadeTransition(opacity: animation, child: child),
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
