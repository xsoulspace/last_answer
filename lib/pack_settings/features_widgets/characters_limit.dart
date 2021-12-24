part of pack_settings;

class CharactersLimitSetting extends HookWidget {
  const CharactersLimitSetting({
    this.note,
    this.updatesStream,
    final Key? key,
  }) : super(key: key);
  final NoteProject? note;
  final StreamController<NoteProjectNotifier>? updatesStream;

  String getInitialLimit({required final SettingsController settings}) {
    int limit;

    if (note != null) {
      limit = note?.charactersLimit ?? 0;
    } else {
      limit = settings.charactersLimitForNewNotes;
    }

    return limit == 0 ? '' : '$limit';
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = SettingsStateScope.of(context);
    final initialText = getInitialLimit(settings: settings);
    final controller = useTextEditingController(text: initialText);
    final state = useCharactersLimitSettingStateState(
      context: context,
      note: note,
      updatesStream: updatesStream,
      controller: controller,
    );

    return Row(
      children: [
        AppIconButton(
          onPressed: state.onSetInstagramLimit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 3,
            ),
            child: Assets.icons.instagramLogo.image(
              width: 18,
              height: 18,
              color: theme.textTheme.bodyText2?.color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autocorrect: false,
            keyboardAppearance: theme.brightness,
            enableSuggestions: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration()
                .applyDefaults(theme.inputDecorationTheme)
                .copyWith(
                  hintText: S.current.charactersUnlimited,
                ),
          ),
        ),
        const SizedBox(width: 2),
        AppIconButton(
          onPressed: controller.text.isEmpty ? null : state.onClearLimit,
          child: const Icon(CupertinoIcons.clear),
        ),
      ],
    );
  }
}
