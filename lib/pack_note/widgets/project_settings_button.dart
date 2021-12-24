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
  final StreamController<NoteProjectNotifier> updatesStream;

  @override
  Widget build(final BuildContext context) {
    useNoteProjectUpdaterState(
      note: note,
      updatesStream: updatesStream,
      context: context,
    );
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: borderPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: borderPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        ),
      ],
    );
  }
}

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
  final StreamController<NoteProjectNotifier> updatesStream;

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
