part of pack_note;

class NoteSettingsButton extends StatelessWidget {
  const NoteSettingsButton({
    required final this.note,
    required this.onRemove,
    required this.updatesStream,
    final Key? key,
  }) : super(key: key);
  final NoteProject note;
  final VoidCallback onRemove;
  final StreamController<NoteProjectNotifier> updatesStream;
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
          height: 100,
          child: MobileNoteSettingsMenu(
            note: note,
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
            note: note,
            onRemove: onRemove,
            updatesStream: updatesStream,
          ),
        );
      },
      icon: Icons.more_vert_rounded,
    );
  }
}
