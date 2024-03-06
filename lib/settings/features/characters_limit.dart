import 'package:flutter/cupertino.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/characters_limit_state.dart';

class CharactersLimitSetting extends HookWidget {
  const CharactersLimitSetting({
    required this.controller,
    super.key,
  });
  final CharactersLimitController controller;

  @override
  Widget build(final BuildContext context) {
    final theme = context.theme;
    final dark = theme.brightness == Brightness.dark;
    useListenable(controller);
    Widget otherButton;

    // TODO(arenukvern): refactor to separate widget
    if (controller.isEditing) {
      otherButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12),
          UiTextField(
            value: controller.limit,
            focusNode: controller.focusNode,
            onChanged: controller.onLimitChanged,
            keyboardType: TextInputType.number,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration()
                .applyDefaults(theme.inputDecorationTheme)
                .copyWith(
                  hintText: context.l10n.charactersUnlimited,
                  constraints: const BoxConstraints(maxWidth: 60),
                ),
          ),
          const Gap(2),
          HoverableButton(
            onPressed: controller.isEditing ? controller.onClearLimit : null,
            child: const Icon(
              CupertinoIcons.clear,
              size: 14,
            ),
          ),
        ],
      );
    } else {
      otherButton = Padding(
        padding: const EdgeInsets.only(right: 8),
        child: HoverableButton(
          onPressed: () => controller.setIsEditing(true),
          child: Text(context.l10n.charactersUnlimited),
        ),
      );
    }
    // TODO(arenukvern): refactor to separate widget

    SvgGenImage vkIcon;
    if (controller.isVkLimit) {
      vkIcon = Assets.icons.vkLogoBlue;
    } else {
      vkIcon = dark ? Assets.icons.vkLogoWhite : Assets.icons.vkLogoBlack;
    }

    // TODO(arenukvern): refactor to separate widget

    AssetGenImage instagramIcon;
    if (controller.isInstagramLimit) {
      instagramIcon = Assets.icons.instagramLogoColorful;
    } else {
      instagramIcon = Assets.icons.instagramLogoBlack;
    }
    // TODO(arenukvern): refactor to separate widget

    AssetGenImage xIcon;
    if (controller.isXLimit) {
      xIcon = dark ? Assets.icons.xLogoBlack : Assets.icons.xLogoWhite;
    } else {
      xIcon = dark ? Assets.icons.xLogoWhite : Assets.icons.xLogoBlack;
    }
    // TODO(arenukvern): refactor to separate widget

    AssetGenImage facebookIcon;
    if (controller.isFacebookLimit) {
      facebookIcon = Assets.icons.fbLogoBlue;
    } else {
      facebookIcon = dark ? Assets.icons.fbLogoWhite : Assets.icons.fbLogoBlack;
    }
    // TODO(arenukvern): refactor to separate widget
    SvgGenImage discordIcon;
    if (controller.isDiscordLimit) {
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
          onTap: controller.onSetInstagramLimit,
          child: instagramIcon.image(
            colorBlendMode: BlendMode.srcIn,
            width: 18,
            height: 18,
            color: controller.isInstagramLimit
                ? null
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
        CharactersLimitButton(
          onTap: controller.onSetTwitterLimit,
          child: ImageGenIcon(
            genImage: xIcon,
            dimension: 18,
          ),
        ),
        CharactersLimitButton(
          onTap: controller.onSetFacebookLimit,
          child: ImageGenIcon(
            genImage: facebookIcon,
            dimension: 18,
          ),
        ),
        CharactersLimitButton(
          onTap: controller.onSetDiscordLimit,
          child: discordIcon.svg(
            width: 16,
            height: 16,
          ),
        ),
        CharactersLimitButton(
          onTap: controller.onSetVkLimit,
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
  Widget build(final BuildContext context) => Card(
        color: context.colorScheme.primaryContainer,
        child: HoverableButton(
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 3,
            ),
            child: child,
          ),
        ),
      );
}

class ImageGenIcon extends StatelessWidget {
  const ImageGenIcon({
    required this.dimension,
    required this.genImage,
    this.color,
    super.key,
  });
  final AssetGenImage genImage;
  final Color? color;
  final double dimension;
  @override
  Widget build(final BuildContext context) => Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: genImage.provider(),
          ),
          color: color,
        ),
      );
}
