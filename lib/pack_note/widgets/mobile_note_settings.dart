import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_note/screens/use_note_project_updater.dart';
import 'package:lastanswer/utils/utils.dart';

class MobileNoteSettingsMenu extends HookWidget {
  const MobileNoteSettingsMenu({
    required this.note,
    required this.onRemove,
    required this.updatesStream,
    super.key,
  });
  static const borderPadding = 8.0;
  final ProjectModelNote note;
  final VoidCallback onRemove;
  final StreamController<NoteProjectNotifier> updatesStream;

  @override
  Widget build(final BuildContext context) {
    useNoteProjectUpdaterState(
      note: note,
      updatesStream: updatesStream,
      context: context,
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
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: CharactersLimitSetting(
                  note: note,
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
