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
    return PopupButton(
      builder: (final context) {
        return ButtonPopup(
          height: 200,
          child: NoteSettingsMenu(
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

class NoteSettingsMenu extends HookWidget {
  const NoteSettingsMenu({
    required final this.note,
    required this.onRemove,
    required this.updatesStream,
    final Key? key,
  }) : super(key: key);
  static const borderPadding = 8.0;
  final NoteProject note;
  final VoidCallback onRemove;
  final StreamController<NoteProjectNotifier> updatesStream;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    useNoteProjectUpdaterState(
      note: note,
      updatesStream: updatesStream,
      context: context,
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
        Divider(
          color: theme.highlightColor,
          height: borderPadding,
          endIndent: borderPadding,
          indent: borderPadding,
        ),
        Expanded(
          child: HoverableArea(
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
                          note: note,
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
