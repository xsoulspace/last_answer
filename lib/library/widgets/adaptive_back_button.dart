part of widgets;

class AdaptiveBackButton extends HookWidget {
  const AdaptiveBackButton({
    required final this.onPressed,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();
    if (isDesktop) {
      final theme = Theme.of(context);
      return MouseRegion(
        onEnter: (final _) => hovered.value = true,
        onExit: (final _) => hovered.value = false,
        child: CupertinoIconButton(
          onPressed: onPressed,
          size: 18,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          backgroundColor: hovered.value ? theme.hoverColor : null,
          icon: Icons.arrow_back_ios_new_rounded,
        ),
      );
    }

    return BackButton(onPressed: onPressed);
  }
}
