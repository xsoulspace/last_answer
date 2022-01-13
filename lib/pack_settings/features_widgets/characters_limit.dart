part of pack_settings;

class CharactersLimitSetting extends HookWidget {
  const CharactersLimitSetting({
    this.note,
    this.updatesStream,
    this.expanded = false,
    final Key? key,
  }) : super(key: key);
  final NoteProject? note;
  final StreamController<NoteProjectNotifier>? updatesStream;
  final bool expanded;

  String getInitialLimit({required final SettingsController settings}) {
    int limit;

    if (note != null) {
      limit = note?.charactersLimit ?? 0;
    } else {
      limit = settings.charactersLimitForNewNotes;
    }

    return limit == 0 ? '' : '$limit';
  }

  static const _customFieldDefaultHeight = 45.0;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final settings = SettingsStateScope.of(context);
    final initialText = getInitialLimit(settings: settings);
    final controller = useTextEditingController(text: initialText);
    final isCustomFieldOpen = useIsBool(initial: expanded);

    final customFieldController = useAnimationController(
      duration: const Duration(milliseconds: 110),
    );

    final customFieldHeight = useAnimation(
      Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(
          0,
          _customFieldDefaultHeight,
        ),
      ).animate(
        CurvedAnimation(
          parent: customFieldController,
          curve: Curves.decelerate,
        ),
      ),
    );
    final customFieldOpacity = customFieldHeight.dy / _customFieldDefaultHeight;

    final state = useCharactersLimitSettingStateState(
      context: context,
      note: note,
      updatesStream: updatesStream,
      controller: controller,
      customFieldController: customFieldController,
      isCustomFieldOpen: isCustomFieldOpen,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
                  color: state.isInstagramLimit
                      ? AppColors.primary
                      : theme.textTheme.bodyText2?.color,
                ),
              ),
            ),
            AppIconButton(
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
                  width: 18,
                  height: 18,
                  color: state.isTwitterLimit
                      ? AppColors.primary
                      : theme.textTheme.bodyText2?.color,
                ),
              ),
            ),
            const Spacer(),
            if (!expanded)
              AppIconButton(
                onPressed: state.onOpenCustomField,
                child: Icon(
                  Platform.isLinux || isAppleDevice
                      ? CupertinoIcons.settings
                      : Icons.settings,
                  color: isCustomFieldOpen.value ? AppColors.primary : null,
                ),
              ),
          ],
        ),
        Opacity(
          opacity: expanded ? 1 : customFieldOpacity,
          child: SizedBox(
            height: expanded ? _customFieldDefaultHeight : customFieldHeight.dy,
            child: Row(
              children: [
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
                  onPressed:
                      controller.text.isEmpty ? null : state.onClearLimit,
                  child: const Icon(CupertinoIcons.clear),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
