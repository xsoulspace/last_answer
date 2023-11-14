import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class NoteProjectNotifier {
  const NoteProjectNotifier({
    this.charactersLimitChanged = false,
    this.positionChanged = false,
  });
  final bool positionChanged;
  final bool charactersLimitChanged;
}

class NoteProjectUpdaterStateDto {
  NoteProjectUpdaterStateDto({
    required final BuildContext context,
  })  : notesState = context.read(),
        folderBloc = context.read();
  final NoteProjectsState notesState;
  final FolderStateNotifier folderBloc;
}

class NoteProjectUpdaterState extends ChangeNotifier {
  NoteProjectUpdaterState({
    required this.note,
    required this.updatesStream,
    required this.dto,
  });

  final NoteProjectUpdaterStateDto dto;
  final NoteProject note;
  final StreamController<NoteProjectNotifier> updatesStream;
  @override
  @mustCallSuper
  void initState() {
    unawaited(
      updatesStream.stream
          .sampleTime(
            const Duration(milliseconds: 700),
          )
          .forEach(onUpdateFolder),
    );
  }

  @override
  @mustCallSuper
  void dispose() {}

  @mustCallSuper
  // ignore: avoid_positional_boolean_parameters
  Future<void> onUpdateFolder(final NoteProjectNotifier notifier) async {
    dto.notesState.put(key: note.id, value: note);

    if (notifier.positionChanged) {
      note.folder?.sortProjectsByDate(project: note);
      dto.folderBloc.notify();
    }

    await note.save();
    if (notifier.charactersLimitChanged) notifyListeners();
  }
}
