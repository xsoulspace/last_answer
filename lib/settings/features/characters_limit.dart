import 'package:flutter/cupertino.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/characters_limit_state.dart';

class CharactersLimitSetting extends HookWidget {
  const CharactersLimitSetting({required this.controller, super.key});
  final CharactersLimitController controller;

  @override
  Widget build(final BuildContext context) {
    final settings = context.watch<UserNotifier>().settings;
    final theme = context.laUi;
    final dark = theme.isDark;
    useListenable(controller);
    Widget otherButton = LaButton(
      variant: LaButtonVariant.link,
      onPressed: () => controller.setIsEditing(true),
      label: context.l10n.charactersUnlimited,
    );

    // TODO(arenukvern): refactor to separate widget
    if (controller.isEditing) {
      otherButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 60),
              child: _LimitField(
                value: controller.limit,
                focusNode: controller.focusNode,
                onChanged: controller.onLimitChanged,
                placeholder: context.l10n.charactersUnlimited,
              ),
            ),
          ),
          LaButton.icon(
            size: LaButtonSize.sm,
            onPressed: controller.isEditing ? controller.onClearLimit : null,
            icon: const Icon(CupertinoIcons.clear, size: 14),
          ),
        ],
      );
    }

    // final isRestricted = settings.isSocialNetworksRestricted &&
    final isRestricted =
        settings.isSocialNetworksRestricted &&
        (uiLocaleNotifier.value == Locales.ru || Envs.store.isRustore);
    final isNotRestricted = !isRestricted;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (isNotRestricted)
          CharactersLimitButton(
            onTap: controller.onSetInstagramLimit,
            child:
                (controller.isInstagramLimit
                        ? Assets.icons.instagramLogoColorful
                        : Assets.icons.instagramLogoBlack)
                    .image(
                      colorBlendMode: BlendMode.srcIn,
                      width: 18,
                      height: 18,
                      color: controller.isInstagramLimit
                          ? null
                          : theme.body.color,
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
            false =>
              dark
                  ? Assets.icons.discordLogoWhite
                  : Assets.icons.discordLogoBlack,
          }.svg(width: 16, height: 16),
        ),
        CharactersLimitButton(
          onTap: controller.onSetVkLimit,
          child: switch (controller.isVkLimit) {
            true => Assets.icons.vkLogoBlue,
            false => dark ? Assets.icons.vkLogoWhite : Assets.icons.vkLogoBlack,
          }.svg(width: 18, height: 18),
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
  Widget build(final BuildContext context) => LaPressable(
    onTap: onTap,
    fill: context.laUi.fieldFill,
    radius: context.laUi.controlRadius,
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
    child: child,
  );
}

/// A [LaField] bound to an external string value (the kit has no `value:`
/// parameter — local sync wrapper preserving the old UiTextField semantics).
class _LimitField extends StatefulWidget {
  const _LimitField({
    required this.value,
    required this.focusNode,
    required this.onChanged,
    required this.placeholder,
  });
  final String? value;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? placeholder;

  @override
  State<_LimitField> createState() => _LimitFieldState();
}

class _LimitFieldState extends State<_LimitField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant final _LimitField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.value ?? '';
    if (newValue != _controller.text) {
      _controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => LaField(
    controller: _controller,
    focusNode: widget.focusNode,
    onChanged: widget.onChanged,
    keyboardType: TextInputType.number,
    autocorrect: false,
    enableSuggestions: false,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    placeholder: widget.placeholder,
    height: 28,
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
      image: DecorationImage(image: genImage.provider()),
      color: color,
    ),
  );
}
