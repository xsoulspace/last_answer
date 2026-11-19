import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_legacy/note/note_view_bloc.dart';
import 'package:lastanswer/ui_legacy/note/widgets/desktop_note_settings.dart';
import 'package:lastanswer/ui_legacy/note/widgets/mobile_note_settings.dart';

class NoteSettingsButton extends StatelessWidget {
  const NoteSettingsButton({super.key});
  @override
  Widget build(final BuildContext context) {
    final bloc = context.read<NoteViewBloc>();
    Future<void> onRemove() => bloc.onRemove(context);
    if (PlatformInfo.isNativeWebDesktop) {
      return LaMenuAnchor.builder(
        closeOnActivate: false,
        alignRight: true,
        entries: [
          LaMenuCustom(
            SizedBox(
              width: 250,
              height: 230,
              child: DesktopNoteSettingsMenu(
                onRemove: onRemove,
                characterLimitController: bloc.characterLimitController,
              ),
            ),
          ),
        ],
        childBuilder: (final context, final anchor) => LaButton.icon(
          icon: const Icon(Icons.more_vert_rounded),
          tooltip: context.l10n.noteSettings,
          onPressed: anchor.toggle,
        ),
      );
    }
    return LaButton.icon(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: context.l10n.noteSettings,
      onPressed: () => unawaited(
        showLaDialog<void>(
          context: context,
          builder: (final dialogContext) => LaDialog(
            titleText: context.l10n.noteSettings,
            content: SizedBox(
              width: MediaQuery.of(dialogContext).size.width - 50,
              height: 150,
              child: MobileNoteSettingsMenu(
                onRemove: onRemove,
                characterLimitController: bloc.characterLimitController,
              ),
            ),
            actions: [
              LaButton(
                label: context.l10n.delete.sentenceCase,
                variant: LaButtonVariant.destructiveGhost,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  unawaited(onRemove());
                },
              ),
              LaButton(
                label: context.l10n.close.sentenceCase,
                variant: LaButtonVariant.ghost,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
