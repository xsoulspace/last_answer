import 'package:flutter/cupertino.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_note/note_view.dart';
import 'package:lastanswer/pack_note/widgets/note_settings_button.dart';

class NoteProjectSideActionBar extends HookWidget {
  const NoteProjectSideActionBar({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final bloc = context.watch<NoteProjectViewBloc>();
    final specialEmojiController = bloc.specialEmojiController;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const NoteSettingsButton(),
        SpecialEmojiButton(
          controller: specialEmojiController,
        ),
        SizedBox(
          height: 34,
          width: 48,
          child: IconShareButton(
            onTap: () {
              unawaited(ProjectSharer.of(context).share(sharable: bloc.note));
            },
          ),
        ),
        EmojiPopup(
          controller: bloc.noteController,
          focusNode: bloc.focusNode,
        ),
        if (Platform.isAndroid || Platform.isIOS)
          IconButton(
            onPressed: () async => bloc.onSwitchKeyboard(
              isKeyboardVisible: specialEmojiController.value.isKeyboardOpen,
            ),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !specialEmojiController.value.isKeyboardOpen
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
