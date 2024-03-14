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
    final settings = context.watch<UserNotifier>().settings;
    final theme = context.theme;
    final dark = theme.brightness == Brightness.dark;
    useListenable(controller);
    Widget otherButton = HoverableButton(
      onPressed: () => controller.setIsEditing(true),
      child: Text(context.l10n.charactersUnlimited),
    );

    // TODO(arenukvern): refactor to separate widget
    if (controller.isEditing) {
      otherButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: UiTextField(
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
                    isDense: true,
                    hintText: context.l10n.charactersUnlimited,
                    constraints: const BoxConstraints(maxWidth: 60),
                  ),
            ),
          ),
          HoverableButton(
            onPressed: controller.isEditing ? controller.onClearLimit : null,
            child: const Icon(
              CupertinoIcons.clear,
              size: 14,
            ),
          ),
        ],
      );
    }

    final isRestricted = settings.isSocialNetworksRestricted;
    final isNotRestricted =
        !isRestricted || uiLocaleNotifier.value != Locales.ru;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (isNotRestricted)
          CharactersLimitButton(
            onTap: controller.onSetInstagramLimit,
            child: (controller.isInstagramLimit
                    ? Assets.icons.instagramLogoColorful
                    : Assets.icons.instagramLogoBlack)
                .image(
              colorBlendMode: BlendMode.srcIn,
              width: 18,
              height: 18,
              color: controller.isInstagramLimit
                  ? null
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        if (isNotRestricted)
          CharactersLimitButton(
            onTap: controller.onSetTwitterLimit,
            child: ImageGenIcon(
              genImage: switch (controller.isXLimit) {
                true =>
                  dark ? Assets.icons.xLogoBlack : Assets.icons.xLogoWhite,
                false =>
                  dark ? Assets.icons.xLogoWhite : Assets.icons.xLogoBlack,
              },
              dimension: 18,
            ),
          ),
        if (isNotRestricted)
          CharactersLimitButton(
            onTap: controller.onSetFacebookLimit,
            child: ImageGenIcon(
              genImage: switch (controller.isFacebookLimit) {
                true => Assets.icons.fbLogoBlue,
                false =>
                  dark ? Assets.icons.fbLogoWhite : Assets.icons.fbLogoBlack,
              },
              dimension: 18,
            ),
          ),
        CharactersLimitButton(
          onTap: controller.onSetDiscordLimit,
          child: switch (controller.isDiscordLimit) {
            true => Assets.icons.discordLogoBlue,
            false => dark
                ? Assets.icons.discordLogoWhite
                : Assets.icons.discordLogoBlack,
          }
              .svg(
            width: 16,
            height: 16,
          ),
        ),
        CharactersLimitButton(
          onTap: controller.onSetVkLimit,
          child: switch (controller.isVkLimit) {
            true => Assets.icons.vkLogoBlue,
            false => dark ? Assets.icons.vkLogoWhite : Assets.icons.vkLogoBlack,
          }
              .svg(
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
