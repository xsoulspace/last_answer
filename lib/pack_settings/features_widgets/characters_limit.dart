part of pack_settings;

class CharactersLimitSetting extends HookWidget {
  const CharactersLimitSetting({
    this.note,
    this.updatesStream,
    super.key,
  });
  final NoteProject? note;
  final StreamController<NoteProjectNotifier>? updatesStream;

  String getInitialLimit({required final GeneralSettingsController settings}) {
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
    final settings = context.watch<GeneralSettingsController>();
    final initialText = getInitialLimit(settings: settings);
    final controller = useTextEditingController(text: initialText);

    final state = useCharactersLimitSettingStateState(
      context: context,
      note: note,
      updatesStream: updatesStream,
      controller: controller,
    );

    Widget otherButton;
    // TODO(arenukvern): refactor to separate widget

    if (state.noLimitIsSet) {
      otherButton = Padding(
        padding: const EdgeInsets.only(right: 8),
        child: HoverableButton(
          onPressed: () => state.setLimit(
            0,
            updateController: true,
            zeroEqualNull: false,
          ),
          child: Text(S.current.charactersUnlimited),
        ),
      );
    } else {
      otherButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
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
    // TODO(arenukvern): refactor to separate widget

    SvgGenImage vkIcon;
    if (state.isVkLimit) {
      vkIcon = Assets.icons.vkLogoBlue;
    } else {
      vkIcon = dark ? Assets.icons.vkLogoWhite : Assets.icons.vkLogoBlack;
    }
    // TODO(arenukvern): refactor to separate widget

    AssetGenImage instagramIcon;
    if (state.isInstagramLimit) {
      instagramIcon = Assets.icons.instagramLogoColorful;
    } else {
      instagramIcon = Assets.icons.instagramLogoBlack;
    }
    // TODO(arenukvern): refactor to separate widget

    SvgGenImage twitterIcon;
    if (state.isTwitterLimit) {
      twitterIcon = Assets.icons.twitterLogoBlue;
    } else {
      twitterIcon =
          dark ? Assets.icons.twitterLogoWhite : Assets.icons.twitterLogoBlack;
    }
    // TODO(arenukvern): refactor to separate widget

    AssetGenImage facebookIcon;
    if (state.isFacebookLimit) {
      facebookIcon = Assets.icons.fbLogoBlue;
    } else {
      facebookIcon = dark ? Assets.icons.fbLogoWhite : Assets.icons.fbLogoBlack;
    }
    // TODO(arenukvern): refactor to separate widget
    SvgGenImage discordIcon;
    if (state.isDiscordLimit) {
      discordIcon = Assets.icons.discordLogoBlue;
    } else {
      discordIcon =
          dark ? Assets.icons.discordLogoWhite : Assets.icons.discordLogoBlack;
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CharactersLimitButton(
          onTap: state.onSetInstagramLimit,
          child: Image.asset(
            instagramIcon.assetName,
            bundle: instagramIcon.bundle,
            package: instagramIcon.package,
            cacheHeight: 36,
            cacheWidth: 36,
            width: 18,
            height: 18,
            color: state.isInstagramLimit
                ? null
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
        CharactersLimitButton(
          onTap: state.onSetTwitterLimit,
          child: twitterIcon.svg(
            width: 16,
            height: 16,
            color: state.isTwitterLimit
                ? AppColors.twitterBlue
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
        CharactersLimitButton(
          onTap: state.onSetFacebookLimit,
          child: Image.asset(
            facebookIcon.assetName,
            bundle: facebookIcon.bundle,
            package: facebookIcon.package,
            cacheHeight: 36,
            cacheWidth: 36,
            width: 18,
            height: 18,
          ),
        ),
        CharactersLimitButton(
          onTap: state.onSetDiscordLimit,
          child: discordIcon.svg(
            width: 16,
            height: 16,
          ),
        ),
        CharactersLimitButton(
          onTap: state.onSetVkLimit,
          child: vkIcon.svg(
            width: 18,
            height: 18,
          ),
        ),
        otherButton,
      ],
    );
  }
}

class CharactersLimitButton extends StatelessWidget {
  const CharactersLimitButton({
    required this.onTap,
    required this.child,
    super.key,
  });
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(final BuildContext context) => HoverableButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 3,
        ),
        child: child,
      ),
    );
}
