import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_note/states/use_note_project_updater.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';

// ignore: long-parameter-list
NoteProjectScreenState useNoteProjectScreenState({
  required final NoteProjectsNotifier notesNotifier,
  required final CurrentFolderNotifier folderNotifier,
  required final ValueNotifier<NoteProject> noteNotifier,
  required final StreamController<NoteProjectUpdateDto> updatesStream,
  required final ServerProjectsSyncService projectsSyncService,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useNoteProjectScreenState',
        state: NoteProjectScreenState(
          noteNotifier: noteNotifier,
          updatesStream: updatesStream,
          folderNotifier: folderNotifier,
          notesNotifier: notesNotifier,
          projectsSyncService: projectsSyncService,
        ),
      ),
    );

class NoteProjectScreenState extends NoteProjectUpdaterState {
  NoteProjectScreenState({
    required super.folderNotifier,
    required super.notesNotifier,
    required super.noteNotifier,
    required super.updatesStream,
    required super.projectsSyncService,
  }) : noteController = TextEditingController(text: noteNotifier.value.note);

  final TextEditingController noteController;

  @override
  void initState() {
    noteController.addListener(onNoteChange);
    super.initState();
  }

  Future<void> onRemove() async {
    final remove = await showRemoveTitleDialog(
      title: note.title,
      context: getContext(),
    );
    if (remove) {
      await removeProject(
        context: getContext(),
        project: note,
        checkIsProjectActive: (final project) => getContext()
            .read<AppRouterController>()
            .checkIsProjectActive(project: project, read: getContext().read),
        onGoHome: onGoHome,
      );
    }
  }

  void onNoteChange() {
    if (note.note == noteController.text) return;
    bool positionChanged = false;
    if (note.title != NoteProject.getTitle(noteController.text)) {
      positionChanged = true;
    } else {
      positionChanged = note.folder?.projectsList.first != note;
    }
    note
      ..note = noteController.text
      ..updatedAt = dateTimeNowUtc();
    updatesStream.add(NoteProjectUpdateDto(positionChanged: positionChanged));
  }

  Future<void> onBack() async {
    closeKeyboard(context: getContext());
    if (note.note.replaceAll(' ', '').isEmpty) {
      getContext().read<NoteProjectsNotifier>().remove(key: note.id);
      await note.deleteWithRelatives(context: getContext());
    }
    onGoHome();
  }

  void onGoHome() => getContext().read<AppRouterController>().toHome();

  @override
  void dispose() {
    noteController
      ..removeListener(onNoteChange)
      ..dispose();
    super.dispose();
  }
}
