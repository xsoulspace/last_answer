part of pack_note;

class MobileNoteSettingsMenu extends HookWidget {
  const MobileNoteSettingsMenu({
    required final this.note,
    required this.onRemove,
    required this.updatesStream,
    final Key? key,
  }) : super(key: key);
  static const borderPadding = 8.0;
  final NoteProject note;
  final VoidCallback onRemove;
  final StreamController<NoteProjectUpdate> updatesStream;

  @override
  Widget build(final BuildContext context) {
    useNoteProjectUpdaterState(
      note: note,
      updatesStream: updatesStream,
      folderNotifier: context.watch(),
      notesNotifier: context.watch(),
    );
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: borderPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: borderPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  '${S.current.charactersLimit}:',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.headline6,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: CharactersLimitSetting(
                  note: note,
                  updatesStream: updatesStream,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
