part of widgets;

class DecoratedActionButton extends StatelessWidget {
  const DecoratedActionButton({
    required this.onPressed,
    this.iconData,
    this.filled = false,
    this.surfaceColor = AppColors.accent3,
    this.text,
    this.textColor,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final IconData? iconData;
  final String? text;
  final bool filled;
  final Color surfaceColor;
  final Color? textColor;

  @override
  Widget build(final BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline6?.copyWith(
          color: textColor,
        );

    final child = iconData != null
        ? Icon(iconData)
        : Text(
            text ?? '',
            style: textStyle,
          );

    if (filled) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          primary: surfaceColor,
        ),
        onPressed: onPressed,
        child: child,
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
        primary: surfaceColor,
      ),
      child: child,
    );
  }
}
