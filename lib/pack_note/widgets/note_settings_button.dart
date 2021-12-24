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
      secondaryMobileAction: isNativeDesktop
          ? null
          : RemoveActionButton(
              onTap: onRemove,
            ),
      builder: (final context) {
        return ButtonPopup(
          height: 200,
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

class RemoveActionButton extends StatelessWidget {
  const RemoveActionButton({
    required this.onTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onTap;
  @override
  Widget build(final BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
        primary: AppColors.accent3,
      ),
      child: Text(
        S.current.delete.sentenceCase,
        style: Theme.of(context)
            .textTheme
            .headline6
            ?.copyWith(color: AppColors.accent3),
      ),
    );
  }
}
