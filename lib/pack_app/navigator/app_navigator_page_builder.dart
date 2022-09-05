import 'package:flutter/material.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/models/route_parameters.dart';
import 'package:lastanswer/pack_app/navigator/app_navigator.dart';
import 'package:lastanswer/pack_app/screens/info/app_info.dart';
import 'package:lastanswer/pack_auth/pack_auth.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_note/pack_note.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class AppNavigatorPageBuilder {
  AppNavigatorPageBuilder({
    required this.context,
  });
  final BuildContext context;
  static final emptyPage = MaterialPage<void>(child: Container());

  RouteState get routeState => popper.routeState;
  AppRouteParameters get params => popper.params;
  String get pathTemplate => popper.pathTemplate;
  void onChangeFolder(final ProjectFolder folder) {
    context.read<CurrentFolderNotifier>().setState(folder);
  }

  bool checkIsProjectActive(final BasicProject project) {
    if (project.id == params.noteId) return true;
    if (project.id == params.ideaId) return true;

    return false;
  }

  Page appInfoPage() {
    return NavigatorPage(
      key: NavigatorValueKeys.info,
      fullscreenDialog: true,
      child: const AppInfoScreen(),
    );
  }

  /// ********************************************
  /// *      SETTINGS START
  /// ********************************************

  Page settingsPage() {
    return const FadedRailPage<void>(
      key: NavigatorValueKeys.settings,
      fullscreenDialog: true,
      child: RouterPopScope(
        child: SettingsScreen(),
      ),
    );
  }

  /// ********************************************
  /// *      SETTINGS END
  /// ********************************************

  Page notePage() {
    return MaterialPage<void>(
      key: NavigatorValueKeys.notesNote,
      restorationId: routeState.route.path,
      fullscreenDialog: DeviceRuntimeType.isNativeDesktop,
      name: routeState.route.path,
      child: RouterPopScope(
        child: NoteProjectScreen(
          onBack: (final note) async {
            if (note.note.replaceAll(' ', '').isEmpty) {
              context.read<NoteProjectsNotifier>().remove(key: note.id);
              await note.deleteWithRelatives(context: context);
            }
            navigatorController.toHome();
          },
          noteId: params.noteId!,
          key: ValueKey(params.noteId),
        ),
      ),
    );
  }

  Page ideaPage() {
    return MaterialPage<void>(
      key: NavigatorValueKeys.ideasIdea,
      fullscreenDialog: DeviceRuntimeType.isNativeDesktop,
      restorationId: routeState.route.path,
      name: routeState.route.path,
      child: RouterPopScope(
        child: IdeaProjectScreen(
          onBack: navigatorController.toHome,
          onAnswerExpand: navigatorController.onIdeaAnswerExpand,
          ideaId: params.ideaId!,
          key: ValueKey(params.ideaId),
        ),
      ),
    );
  }

  Page ideaAnswerPage() {
    return MaterialPage<void>(
      fullscreenDialog: true,
      key: NavigatorValueKeys.ideasIdeaAnswer,
      restorationId: routeState.route.path,
      name: routeState.route.path,
      child: RouterPopScope(
        child: IdeaAnswerScreen(
          onUnknown: navigatorController.onUnknownIdeaAnswer,
          onBack: (final idea) =>
              navigatorController.toIdeaScreen(ideaId: idea.id),
          answerId: params.answerId!,
          ideaId: params.ideaId!,
          key: ValueKey('${params.ideaId}-${params.answerId}'),
        ),
      ),
    );
  }

  Page createIdeaPage() {
    return MaterialPage<void>(
      key: NavigatorValueKeys.createIdea,
      fullscreenDialog: true,
      child: RouterPopScope(
        child: CreateIdeaProjectScreen(
          onBack: navigatorController.toHome,
          onCreate: navigatorController.onCreateIdea,
        ),
      ),
    );
  }

  Page signInPage() {
    return const MaterialPage<void>(
      key: NavigatorValueKeys.signIn,
      fullscreenDialog: true,
      child: RouterPopScope(
        child: GlobalSignInScreen(),
      ),
    );
  }
}
