part of widgets;

class OutlinedActionButton extends StatelessWidget {
  const OutlinedActionButton({
    required this.onPressed,
    this.text,
    this.iconData,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final IconData? iconData;
  final String? text;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primary : AppColors.primary1;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(color: primaryColor),
        primary: primaryColor,
      ),
      onPressed: onPressed,
      child: iconData != null
          ? Icon(iconData)
          : Text(
              text ?? '',
              style: theme.textTheme.headline6?.copyWith(
                color: primaryColor,
              ),
            ),
    );
  }
}
