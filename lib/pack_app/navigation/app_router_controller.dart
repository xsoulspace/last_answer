import 'dart:async';

import 'package:flutter/material.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_app/models/models.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_settings/abstract/general_settings_controller.dart';
import 'package:lastanswer/pack_settings/sync/server_sync_services/server_projects_sync_service.dart';
import 'package:lastanswer/state/current_folder_notifier.dart';
import 'package:lastanswer/state/projects_notifiers.dart';
import 'package:provider/provider.dart';

class AppRouterController extends RouterController {
  AppRouterController.use(super.read) : super.use();

  bool checkIsProjectActive({
    required final BasicProject project,
    required final Locator read,
  }) {
    final routeParams =
        AppRouteParameters.fromJson(read<RouteState>().route.parameters);
    if (project.id == routeParams.noteId) return true;
    if (project.id == routeParams.ideaId) return true;
    return false;
  }

  void toHome() => to(NavigationRoutes.home);
  void toSignIn() => to(NavigationRoutes.signIn);
  void toSignUp() => to(NavigationRoutes.signUp);

  void toSettings() => to(NavigationRoutes.settings);
  void toAppInfo() => to(NavigationRoutes.appInfo);

  Future<void> toNoteScreen({
    required final BuildContext context,
    final String? noteId,
  }) async {
    final read = context.read;

    String resolvedNoteId = noteId ?? '';
    if (resolvedNoteId.isEmpty) {
      final folderNotifier = read<CurrentFolderNotifier>();
      final settingsNotifier = read<GeneralSettingsController>();
      final currentFolder = folderNotifier.state;
      final projectsSyncService = context.read<ServerProjectsSyncService>();
      final newNote = await NoteProject.create(
        folder: currentFolder,
        charactersLimit: settingsNotifier.charactersLimitForNewNotes,
        context: context,
      );
      folderNotifier.notify();
      resolvedNoteId = newNote.id;
      unawaited(projectsSyncService.upsert([newNote]));
    }

    return to(NavigationRoutes.getNotePath(noteId: resolvedNoteId));
  }

  /// ******************************
  ///         IDEAS
  /// ******************************

  void toCreateIdea() => to(NavigationRoutes.createIdea);
  void toIdeaScreen({required final String ideaId}) =>
      to(NavigationRoutes.getIdeaPath(ideaId: ideaId));

  Future<void> onCreateIdea({
    required final String title,
    required final BuildContext context,
  }) async {
    final read = context.read;
    final folderNotifier = read<CurrentFolderNotifier>();
    final projectsSyncService = read<ServerProjectsSyncService>();
    final currentFolder = folderNotifier.state;
    final questionsNotifier = read<IdeaProjectQuestionsNotifier>();

    final idea = await IdeaProject.create(
      title: title,
      folder: currentFolder,
      context: context,
      newQuestion: questionsNotifier.state.values.first,
    );
    folderNotifier.notify();

    to(NavigationRoutes.getIdeaPath(ideaId: idea.id));
    unawaited(projectsSyncService.upsert([idea]));
  }

  Future<void> onExpandIdeaAnswer(
    final IdeaProjectAnswer answer,
    final IdeaProject idea,
  ) async =>
      to(
        NavigationRoutes.getIdeaAnswerPath(
          ideaId: idea.id,
          answerId: answer.id,
        ),
      );

  Future<void> onUnknownIdeaAnswer(
    final IdeaProject idea,
  ) async =>
      toIdeaScreen(ideaId: idea.id);

  void toFolder({
    required final ProjectFolder folder,
    required final Locator read,
  }) {
    read<CurrentFolderNotifier>().setState(folder);
  }

  /// ******************************
  ///         Handlers
  /// ******************************

  void onProjectTap({
    required final BasicProject project,
    required final BuildContext context,
  }) {
    if (project is IdeaProject) {
      toIdeaScreen(ideaId: project.id);
    } else if (project is NoteProject) {
      toNoteScreen(noteId: project.id, context: context);
    } else {
      throw UnimplementedError();
    }
  }
}
