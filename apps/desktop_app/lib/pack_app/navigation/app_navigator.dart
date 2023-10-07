import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/models/models.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_app/screens/home_mouse/home_mouse_mobile_screen.dart';
import 'package:lastanswer/pack_app/screens/home_mouse/home_mouse_tablet_screen.dart';
import 'package:lastanswer/pack_auth/pack_auth.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_note/pack_note.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';
import 'package:ui_kit/ui_kit.dart';

class AppNavigator extends HookWidget {
  const AppNavigator({
    required this.navigatorKey,
    super.key,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  Widget build(final BuildContext context) {
    context.watch<RouteState>();
    final keys = useState(const _PageBuilderKeys());
    final pageBuilder = _PageBuilder.use(keys: keys.value, read: context.read);
    final uiTheme = UiTheme.of(context);

    RouterLayoutBuilder layoutBuilder;

    switch (uiTheme.persistentFormFactors.width) {
      case WidthFormFactor.desktop:
      case WidthFormFactor.tablet:
        switch (uiTheme.customizableFormFactors.controls) {
          case ControlsFormFactor.mouse:
            layoutBuilder = _MouseTabletLayoutBuilder(pageBuilder: pageBuilder);
          case ControlsFormFactor.touch:
            // TODO(arenukvern): replace with _AppTouchLayoutBuilder
            layoutBuilder = _MouseTabletLayoutBuilder(pageBuilder: pageBuilder);
        }
      case WidthFormFactor.mobile:
        switch (uiTheme.customizableFormFactors.controls) {
          case ControlsFormFactor.mouse:
            layoutBuilder = _MouseMobileLayoutBuilder(pageBuilder: pageBuilder);
          case ControlsFormFactor.touch:
            // TODO(arenukvern): replace with _AppTouchLayoutBuilder
            layoutBuilder = _MouseMobileLayoutBuilder(pageBuilder: pageBuilder);
        }
    }

    return Navigator(
      key: navigatorKey,
      onPopPage: const RouterPopper().onPopPage,
      pages: layoutBuilder.buildPages(),
    );
  }
}

@immutable
class _PageBuilderKeys {
  const _PageBuilderKeys();
  ValueKey get home => const ValueKey('home');
  ValueKey get projectsMobile => const ValueKey('projectsSmall');
  ValueKey get projectsTabletPage => const ValueKey('projectsTabletPage');
  ValueKey get projectsTabletNavigator =>
      const ValueKey('projectsTabletNavigator');
  ValueKey get info => const ValueKey('info');
  ValueKey get settings => const ValueKey('settings');
  ValueKey get notesNote => const ValueKey('notesNote');
  ValueKey get ideasIdea => const ValueKey('ideasIdea');
  ValueKey get ideasIdeaAnswer => const ValueKey('ideasIdeaAnswer');
  ValueKey get createIdea => const ValueKey('createIdea');
  ValueKey get signIn => const ValueKey('signIn');
}

class _PageBuilder extends RouterPageBuilder<AppRouterController> {
  _PageBuilder.use({
    required this.keys,
    required super.read,
  }) : super.use();
  final _PageBuilderKeys keys;

  void onChangeFolder({
    required final ProjectFolder folder,
    required final BuildContext context,
  }) {
    context.read<CurrentFolderNotifier>().setState(folder);
  }

  static final emptyPage = NavigatorPage(
    child: const EmptyScreen(isEmpty: true),
    key: const ValueKey('loading-screen'),
  );

  Page appInfoPage() => NavigatorPage(
        key: keys.info,
        fullscreenDialog: true,
        child: const AppInfoScreen(),
      );

  /// ********************************************
  /// *      SETTINGS START
  /// ********************************************

  Page settingsPage() => FadedRailPage<void>(
        key: keys.settings,
        fullscreenDialog: true,
        child: const RouterPopScope(
          child: SettingsScreen(),
        ),
      );

  /// ********************************************
  /// *      SETTINGS END
  /// ********************************************

  Page notePage() => MaterialPage<void>(
        key: keys.notesNote,
        restorationId: routeState.route.path,
        fullscreenDialog: DeviceRuntimeType.isNativeDesktop,
        name: routeState.route.path,
        child: RouterPopScope(
          child: Builder(
            builder: (final context) {
              final params =
                  AppRouteParameters.fromJson(routeState.route.parameters);
              return NoteProjectScreen(
                noteId: params.noteId,
                key: ValueKey(params.noteId),
              );
            },
          ),
        ),
      );

  Page ideaPage() => MaterialPage<void>(
        key: keys.ideasIdea,
        fullscreenDialog: DeviceRuntimeType.isNativeDesktop,
        restorationId: routeState.route.path,
        name: routeState.route.path,
        child: RouterPopScope(
          child: Builder(
            builder: (final context) {
              final params =
                  AppRouteParameters.fromJson(routeState.route.parameters);
              return IdeaProjectScreen(
                ideaId: params.ideaId,
                key: ValueKey(params.ideaId),
              );
            },
          ),
        ),
      );

  Page ideaAnswerPage() => MaterialPage<void>(
        fullscreenDialog: true,
        key: keys.ideasIdeaAnswer,
        restorationId: routeState.route.path,
        name: routeState.route.path,
        child: RouterPopScope(
          child: Builder(
            builder: (final context) {
              final params =
                  AppRouteParameters.fromJson(routeState.route.parameters);
              return IdeaAnswerScreen(
                answerId: params.answerId,
                ideaId: params.ideaId,
                key: ValueKey('${params.ideaId}-${params.answerId}'),
              );
            },
          ),
        ),
      );

  Page createIdeaPage() => MaterialPage<void>(
        key: keys.createIdea,
        fullscreenDialog: true,
        child: const RouterPopScope(
          child: CreateIdeaProjectScreen(),
        ),
      );

  Page signInPage() => MaterialPage<void>(
        key: keys.signIn,
        fullscreenDialog: true,
        child: const RouterPopScope(
          child: GlobalSignInScreen(),
        ),
      );
}

class _MouseMobileLayoutBuilder
    extends RouterLayoutBuilder<AppRouterController, _PageBuilder> {
  _MouseMobileLayoutBuilder({required super.pageBuilder});
  @override
  List<Page> buildPages() {
    final pages = <Page>[
      NavigatorPage(
        key: pageBuilder.keys.projectsMobile,
        child: const HomeMouseMobileScreen(),
      ),
      if (pathTemplate.startsWith(NavigationRoutes.settings)) ...[
        pageBuilder.settingsPage(),
      ] else if (pathTemplate == NavigationRoutes.appInfo)
        pageBuilder.appInfoPage()
      else if (pathTemplate == NavigationRoutes.createIdea)
        pageBuilder.createIdeaPage()
      else if (pathTemplate == NavigationRoutes.note)
        pageBuilder.notePage()
      else if (pathTemplate.contains(NavigationRoutes.idea)) ...[
        pageBuilder.ideaPage(),
        if (pathTemplate == NavigationRoutes.ideaAnswer)
          pageBuilder.ideaAnswerPage(),
      ]
    ];
    return pages;
  }
}

class _MouseTabletLayoutBuilder
    extends RouterLayoutBuilder<AppRouterController, _PageBuilder> {
  _MouseTabletLayoutBuilder({required super.pageBuilder});
  @override
  List<Page> buildPages() {
    final pages = <Page>[
      if (pathTemplate.startsWith(NavigationRoutes.home))
        NavigatorPage(
          key: pageBuilder.keys.projectsTabletPage,
          child: HomeMouseTabletScreen(
            contentBuilder: (final context) => Navigator(
              key: pageBuilder.keys.projectsTabletNavigator,
              onGenerateRoute: (final _) => null,
              pages: [
                if (pathTemplate == NavigationRoutes.note)
                  pageBuilder.notePage()
                else if (pathTemplate.contains(NavigationRoutes.idea))
                  pageBuilder.ideaPage()
                else
                  _PageBuilder.emptyPage,
              ],
              onPopPage: (final route, final result) => route.didPop(result),
            ),
          ),
        )
      else
        _PageBuilder.emptyPage,
      if (pathTemplate == NavigationRoutes.createIdea)
        pageBuilder.createIdeaPage()
      else if (pathTemplate == NavigationRoutes.ideaAnswer)
        pageBuilder.ideaAnswerPage()
      else if (pathTemplate.startsWith(NavigationRoutes.settings)) ...[
        pageBuilder.settingsPage(),
      ] else if (pathTemplate == NavigationRoutes.appInfo)
        pageBuilder.appInfoPage(),
    ];
    return pages;
  }
}
