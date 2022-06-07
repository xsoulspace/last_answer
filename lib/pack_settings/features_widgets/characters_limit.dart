import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_note/pack_note.dart';
import 'package:lastanswer/pack_settings/abstract/general_settings_controller.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit_state.dart';
import 'package:provider/provider.dart';

class CharactersLimitSetting extends HookWidget {
  const CharactersLimitSetting({
    this.noteNotifier,
    this.updatesStream,
    final Key? key,
  }) : super(key: key);
  final ValueNotifier<NoteProject>? noteNotifier;
  final StreamController<NoteProjectUpdateDto>? updatesStream;

  String getInitialLimit({required final GeneralSettingsController settings}) {
    int limit;

    if (noteNotifier != null) {
      limit = noteNotifier?.value.charactersLimit ?? 0;
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
      noteNotifier: noteNotifier,
      updatesStream: updatesStream,
      controller: controller,
    );

    Widget otherButton;
    // TODO(arenukvern): refactor to separate widget

    if (state.noLimitIsSet) {
      otherButton = Padding(
        padding: const EdgeInsets.only(right: 8.0),
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
                : theme.textTheme.bodyText2?.color,
          ),
        ),
        CharactersLimitButton(
          onTap: state.onSetTwitterLimit,
          child: twitterIcon.svg(
            width: 16,
            height: 16,
            color: state.isTwitterLimit
                ? AppColors.twitterBlue
                : theme.textTheme.bodyText2?.color,
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
    final Key? key,
  }) : super(key: key);
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return HoverableButton(
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
}
