import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/note/note_view_bloc.dart';
import 'package:lastanswer/pack_note/widgets/desktop_note_settings.dart';
import 'package:lastanswer/pack_note/widgets/mobile_note_settings.dart';

class NoteSettingsButton extends StatelessWidget {
  const NoteSettingsButton({
    super.key,
  });
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<NoteViewBloc>();
    Future<void> onRemove() async => bloc.onRemove(context);
    return PopupButton(
      title: Text(
        context.l10n.noteSettings,
        style: theme.textTheme.titleLarge,
      ),
      mobileBuilder: (final context) => SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: 150,
        child: MobileNoteSettingsMenu(
          onRemove: onRemove,
          characterLimitController: bloc.characterLimitController,
        ),
      ),
      onMobileRemove: onRemove,
      builder: (final context) => ButtonPopup(
        height: 230,
        child: DesktopNoteSettingsMenu(
          onRemove: onRemove,
          characterLimitController: bloc.characterLimitController,
        ),
      ),
      icon: Icons.more_vert_rounded,
    );
  }
}
