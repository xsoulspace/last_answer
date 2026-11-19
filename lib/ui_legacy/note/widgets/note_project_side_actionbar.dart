import 'package:flutter/cupertino.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_legacy/note/note_view_bloc.dart';
import 'package:lastanswer/ui_legacy/note/widgets/note_asset_attach_sheet.dart';
import 'package:lastanswer/ui_legacy/note/widgets/note_settings_button.dart';
import 'package:lastanswer/ui_legacy/legacy_kit/legacy_kit.dart';

class NoteProjectSideActionBar extends HookWidget {
  const NoteProjectSideActionBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final bloc = context.watch<NoteViewBloc>();

    final specialEmojiController = bloc.specialEmojiController;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children:
          [
                const NoteSettingsButton(),
                SizedBox(
                  height: 34,
                  width: 48,
                  child: LaButton.icon(
                    key: const Key('note.attachImage'),
                    tooltip: context.l10n.attachImage,
                    onPressed: () => unawaited(
                      showNoteAssetAttachSheet(
                        context,
                        noteId: bloc.note.id,
                        onAssets: bloc.addAssets,
                      ),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                ),
                SpecialEmojiButton(controller: specialEmojiController),
                SizedBox(
                  height: 34,
                  width: 48,
                  child: ShareIconButton(
                    onTap: () {
                      unawaited(ProjectSharer.of(context).share(bloc.note));
                    },
                  ),
                ),
                EmojiPopup(
                  controller: bloc.noteController,
                  focusNode: bloc.focusNode,
                ),
                if (Platform.isAndroid || Platform.isIOS)
                  AnimatedBuilder(
                    animation: bloc.keyboardVisibilityController,
                    builder: (final context, final child) => LaButton.icon(
                      onPressed: bloc.onSwitchKeyboard,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: !bloc.keyboardVisibilityController.value
                            ? const Icon(CupertinoIcons.keyboard)
                            : const Icon(
                                CupertinoIcons.keyboard_chevron_compact_down,
                              ),
                      ),
                    ),
                  ),
              ]
              .map(
                (final e) =>
                    Padding(padding: const EdgeInsets.only(top: 15), child: e),
              )
              .toList(),
    );
  }
}
