part of '../widgets.dart';

class CupertinoCloseButton extends HookWidget {
  const CupertinoCloseButton({
    required this.onPressed,
    super.key,
  });
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (final _) => hovered.value = true,
      onExit: (final _) => hovered.value = false,
      child: CupertinoButton(
        minSize: 0,
        borderRadius: defaultBorderRadius,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        color: hovered.value ? theme.hoverColor : null,
        onPressed: onPressed,
        child: const Icon(
          CupertinoIcons.clear_thick,
          size: 24,
        ),
      ),
    );
  }
}
