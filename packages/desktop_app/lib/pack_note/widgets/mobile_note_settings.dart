import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/pack_note/states/use_note_project_updater.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:provider/provider.dart';

class MobileNoteSettingsMenu extends HookWidget {
  const MobileNoteSettingsMenu({
    required this.noteNotifier,
    required this.onRemove,
    required this.updatesStream,
    final Key? key,
  }) : super(key: key);
  static const borderPadding = 8.0;
  final ValueNotifier<NoteProject> noteNotifier;
  final VoidCallback onRemove;
  final StreamController<NoteProjectUpdateDto> updatesStream;

  @override
  Widget build(final BuildContext context) {
    useNoteProjectUpdaterState(
      projectsSyncService: context.read(),
      noteNotifier: noteNotifier,
      updatesStream: updatesStream,
      folderNotifier: context.watch(),
      notesNotifier: context.watch(),
    );
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: borderPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: borderPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  '${S.current.charactersLimit}:',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.headline6,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: CharactersLimitSetting(
                  noteNotifier: noteNotifier,
                  updatesStream: updatesStream,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
