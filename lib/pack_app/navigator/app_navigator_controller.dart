import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigator/app_routes.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

@immutable
class AppNavigatorController {
  const AppNavigatorController.use({
    required final this.context,
    required this.screenLayout,
  });
  final BuildContext context;
  final ScreenLayout screenLayout;
  BeamState get route =>
      Beamer.of(context).currentBeamLocation.state as BeamState;
  void go(final AppRouteName routeName) => context.beamToNamed(routeName);
  void goHome() => go(AppRoutesName.home);

  void pop() {
    final path = route.pathWithoutLastSegment;
    go(path);
  }

  void goBackFromSettings() {
    if (route.pathTemplate == AppRoutesName.settings || screenLayout.notSmall) {
      goHome();
    } else {
      goSettings();
    }
  }

  void goSettings() => go(AppRoutesName.settings);
  void goAppInfo() => go(AppRoutesName.appInfo);
  void goSignIn() => go(AppRoutesName.signUp);

  Future<void> goNoteScreen({final String? noteId}) async {
    String resolvedNoteId = noteId ?? '';
    if (resolvedNoteId.isEmpty) {
      final folderNotifier = context.read<CurrentFolderNotifier>();
      final settingsNotifier = context.read<GeneralSettingsController>();
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

    return go(AppRoutesName.getNotePath(noteId: resolvedNoteId));
  }

  /// ******************************
  ///         IDEAS
  /// ******************************

  void goCreateIdea() => go(AppRoutesName.createIdea);
  void goIdeaScreen({required final String ideaId}) =>
      go(AppRoutesName.getIdeaPath(ideaId: ideaId));

  Future<void> onCreateIdea(final String title) async {
    final folderNotifier = context.read<CurrentFolderNotifier>();
    final projectsSyncService = context.read<ServerProjectsSyncService>();
    final currentFolder = folderNotifier.state;
    final questionsNotifier = context.read<IdeaProjectQuestionsNotifier>();

    final idea = await IdeaProject.create(
      title: title,
      folder: currentFolder,
      context: context,
      newQuestion: questionsNotifier.state.values.first,
    );
    folderNotifier.notify();
    go(AppRoutesName.getIdeaPath(ideaId: idea.id));
    unawaited(projectsSyncService.upsert([idea]));
  }

  Future<void> onIdeaAnswerExpand(
    final IdeaProjectAnswer answer,
    final IdeaProject idea,
  ) async =>
      go(
        AppRoutesName.getIdeaAnswerPath(
          ideaId: idea.id,
          answerId: answer.id,
        ),
      );

  Future<void> onUnknownIdeaAnswer(
    final String answerId,
    final IdeaProject idea,
  ) async =>
      goIdeaScreen(ideaId: idea.id);

  /// ******************************
  ///         Handlers
  /// ******************************

  void onProjectTap(final BasicProject project) {
    if (project is IdeaProject) {
      goIdeaScreen(ideaId: project.id);
    } else if (project is NoteProject) {
      goNoteScreen(noteId: project.id);
    } else {
      throw UnimplementedError();
    }
  }
}
