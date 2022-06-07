import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_note/states/use_note_project_updater.dart';
import 'package:lastanswer/pack_note/widgets/desktop_note_settings.dart';
import 'package:lastanswer/pack_note/widgets/mobile_note_settings.dart';

class NoteSettingsButton extends StatelessWidget {
  const NoteSettingsButton({
    required final this.noteNotifier,
    required this.onRemove,
    required this.updatesStream,
    final Key? key,
  }) : super(key: key);
  final ValueNotifier<NoteProject> noteNotifier;
  final VoidCallback onRemove;
  final StreamController<NoteProjectUpdateDto> updatesStream;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return PopupButton(
      title: Text(
        S.current.noteSettings,
        style: theme.textTheme.headline6,
      ),
      mobileBuilder: (final context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          height: 150,
          child: MobileNoteSettingsMenu(
            noteNotifier: noteNotifier,
            onRemove: onRemove,
            updatesStream: updatesStream,
          ),
        );
      },
      onMobileRemove: onRemove,
      builder: (final context) {
        return ButtonPopup(
          height: 230,
          child: DesktopNoteSettingsMenu(
            noteNotifier: noteNotifier,
            onRemove: onRemove,
            updatesStream: updatesStream,
          ),
        );
      },
      icon: Icons.more_vert_rounded,
    );
  }
}
