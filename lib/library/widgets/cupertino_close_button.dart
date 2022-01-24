part of widgets;

class CupertinoCloseButton extends HookWidget {
  const CupertinoCloseButton({
    required final this.onPressed,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();
    final focusNode = useFocusNode();
    final theme = Theme.of(context);

    return Focus(
      focusNode: focusNode,
      onKey: (final focusNode, final key) {
        if (key.isKeyPressed(LogicalKeyboardKey.escape)) {
          onPressed();
        }

        return KeyEventResult.handled;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (final _) => hovered.value = true,
        onExit: (final _) => hovered.value = false,
        child: CupertinoButton(
          minSize: 0,
          borderRadius: defaultBorderRadius,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          color: hovered.value ? theme.hoverColor : null,
          onPressed: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                CupertinoIcons.clear_thick,
                size: 24,
              ),
              // Text(S.current.esc)
            ],
          ),
        ),
      ),
    );
  }
}
