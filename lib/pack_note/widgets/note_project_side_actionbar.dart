import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_note/states/use_note_project_updater.dart';
import 'package:lastanswer/pack_note/widgets/note_settings_button.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:universal_io/io.dart';

class NoteProjectSideActionBar extends HookWidget {
  const NoteProjectSideActionBar({
    required this.noteNotifier,
    required this.onRemove,
    required this.updatesStream,
    required this.noteController,
    required this.noteFocusNode,
    required this.showEmojiKeyboard,
    required this.closeEmojiKeyboard,
    required this.isEmojiKeyboardOpen,
    final Key? key,
  }) : super(key: key);

  final ValueNotifier<NoteProject> noteNotifier;
  final FutureVoidCallback onRemove;
  final StreamController<NoteProjectUpdateDto> updatesStream;
  final TextEditingController noteController;
  final VoidCallback showEmojiKeyboard;
  final VoidCallback closeEmojiKeyboard;
  final FocusNode noteFocusNode;
  final ValueNotifier<bool> isEmojiKeyboardOpen;

  Future<void> onSwitchKeyboard({
    required final bool isKeyboardVisible,
  }) async {
    void switchKeyboard({
      final bool forceToOpen = false,
    }) {
      if (isKeyboardVisible && !forceToOpen) {
        SoftKeyboard.close();
      } else {
        if (noteFocusNode.hasFocus) {
          SoftKeyboard.open();
        } else {
          noteFocusNode.requestFocus();
        }
      }
    }

    if (isEmojiKeyboardOpen.value) {
      closeEmojiKeyboard();
      switchKeyboard(forceToOpen: true);
    } else {
      switchKeyboard();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final isKeyboardVisible = useKeyboardVisibility();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        NoteSettingsButton(
          noteNotifier: noteNotifier,
          onRemove: onRemove,
          updatesStream: updatesStream,
        ),
        SpecialEmojiButton(
          controller: noteController,
          focusNode: noteFocusNode,
          onShowEmojiKeyboard: showEmojiKeyboard,
        ),
        SizedBox(
          height: 34,
          width: 48,
          child: IconShareButton(
            onTap: () {
              ProjectSharer.of(context).share(project: noteNotifier.value);
            },
          ),
        ),
        EmojiPopup(
          controller: noteController,
          focusNode: noteFocusNode,
        ),
        if (Platform.isAndroid || Platform.isIOS)
          IconButton(
            onPressed: () => onSwitchKeyboard(
              isKeyboardVisible: isKeyboardVisible.value,
            ),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isEmojiKeyboardOpen.value || !isKeyboardVisible.value
                  ? const Icon(
                      CupertinoIcons.keyboard,
                    )
                  : const Icon(
                      CupertinoIcons.keyboard_chevron_compact_down,
                    ),
            ),
          ),
      ]
          .map(
            (final e) => Padding(
              padding: const EdgeInsets.only(top: 15),
              child: e,
            ),
          )
          .toList(),
    );
  }
}
