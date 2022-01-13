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
    final dark = theme.brightness == Brightness.dark;
    final settings = SettingsStateScope.of(context);
    final initialText = getInitialLimit(settings: settings);
    final controller = useTextEditingController(text: initialText);

    final state = useCharactersLimitSettingStateState(
      context: context,
      note: note,
      updatesStream: updatesStream,
      controller: controller,
    );

    Widget otherButton;
    if (state.noLimitIsSet) {
      otherButton = Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: HoverableButton(
          onPressed: () => state.setLimit(
            0,
            updateController: true,
            zeroEqualNull: false,
          ),
          child: AnimatedBuilder(
            animation: settings,
            builder: (final context, final _) =>
                Text(S.current.charactersUnlimited),
          ),
        ),
      );
    } else {
      otherButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
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
          HoverableButton(
            onPressed: controller.text.isEmpty ? null : state.onClearLimit,
            child: const Icon(
              CupertinoIcons.clear,
              size: 14,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 14,
      children: [
        HoverableButton(
          onPressed: state.onSetInstagramLimit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 3,
            ),
            child: Assets.icons.instagramLogo.image(
              width: 18,
              height: 18,
              color: state.isInstagramLimit
                  ? AppColors.primary
                  : theme.textTheme.bodyText2?.color,
            ),
          ),
        ),
        HoverableButton(
          onPressed: state.onSetTwitterLimit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 3,
            ),
            child: (dark
                    ? Assets.icons.twitterLogoBlack
                    : Assets.icons.twitterLogoWhite)
                .svg(
              width: 16,
              height: 16,
              color: state.isTwitterLimit
                  ? AppColors.primary
                  : theme.textTheme.bodyText2?.color,
            ),
          ),
        ),
        otherButton,
      ],
    );
  }
}
