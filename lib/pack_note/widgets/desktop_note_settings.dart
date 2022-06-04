part of pack_note;

class DesktopNoteSettingsMenu extends HookWidget {
  const DesktopNoteSettingsMenu({
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
    final theme = Theme.of(context);

    useNoteProjectUpdaterState(
      note: note,
      updatesStream: updatesStream,
      context: context,
    );
    final divider = Divider(
      color: theme.highlightColor,
      height: borderPadding,
      endIndent: borderPadding,
      indent: borderPadding,
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
        divider,
        Expanded(
          child: HoverableArea(
            clickable: false,
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
