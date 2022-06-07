import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_note/states/use_note_project_updater.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

class DesktopNoteSettingsMenu extends HookWidget {
  const DesktopNoteSettingsMenu({
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
    final theme = Theme.of(context);

    useNoteProjectUpdaterState(
      projectsSyncService: context.read(),
      noteNotifier: noteNotifier,
      updatesStream: updatesStream,
      folderNotifier: context.watch(),
      notesNotifier: context.watch(),
    );
    final divider = Divider(
      color: theme.highlightColor,
      height: borderPadding,
      endIndent: borderPadding,
      indent: borderPadding,
    );

    return Column(
      children: [
        const SizedBox(height: borderPadding),
        HovarableListTile(
          onTap: onRemove,
          leadingBuilder: (final context, final hovered) {
            return Icon(
              Icons.delete_outline_rounded,
              color: hovered ? AppColors.accent3 : theme.highlightColor,
            );
          },
          titleBuilder: (final context, final hovered) {
            return Opacity(
              opacity: hovered ? 1.0 : 0.7,
              child: Text(
                S.current.deleteThisNote.sentenceCase,
              ),
            );
          },
        ),
        const SizedBox(height: borderPadding * 2),
        divider,
        Expanded(
          child: HoverableArea(
            clickable: false,
            builder: (final context, final hovered) {
              return Opacity(
                opacity: hovered ? 1.0 : 0.7,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: borderPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: borderPadding * 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${S.current.charactersLimit}:',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headline6,
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: CharactersLimitSetting(
                          noteNotifier: noteNotifier,
                          updatesStream: updatesStream,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
