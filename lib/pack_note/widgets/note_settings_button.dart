part of pack_note;

class NoteSettingsButton extends StatelessWidget {
  const NoteSettingsButton({
    required this.note,
    required this.onRemove,
    required this.updatesStream,
    super.key,
  });
  final NoteProject note;
  final VoidCallback onRemove;
  final StreamController<NoteProjectNotifier> updatesStream;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return PopupButton(
      title: Text(
        S.current.noteSettings,
        style: theme.textTheme.titleLarge,
      ),
      mobileBuilder: (final context) => SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: 150,
        child: MobileNoteSettingsMenu(
          note: note,
          onRemove: onRemove,
          updatesStream: updatesStream,
        ),
      ),
      onMobileRemove: onRemove,
      builder: (final context) => ButtonPopup(
        height: 230,
        child: DesktopNoteSettingsMenu(
          note: note,
          onRemove: onRemove,
          updatesStream: updatesStream,
        ),
      ),
      icon: Icons.more_vert_rounded,
    );
  }
}
