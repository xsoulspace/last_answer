part of widgets;

class HoverableButton extends StatelessWidget {
  const HoverableButton({
    required this.onPressed,
    required this.child,
    super.key,
  });
  final VoidCallback? onPressed;
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return HoverableArea(
      builder: (final context, final hovered) => CupertinoButton(
        minSize: 0,
        borderRadius: defaultBorderRadius,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        color: hovered && onPressed != null ? theme.hoverColor : null,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
