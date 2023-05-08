import 'package:flutter/material.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:ui_kit/ui_kit.dart';

class OutlinedActionButton extends StatelessWidget {
  const OutlinedActionButton({
    required this.onPressed,
    this.text,
    this.iconData,
    this.loading = false,
    super.key,
  });
  final VoidCallback? onPressed;
  final IconData? iconData;
  final String? text;
  final bool loading;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primary : AppColors.primary1;
    Widget child;

    if (loading) {
      child = const CircularProgress();
    } else if (iconData != null) {
      child = Icon(iconData);
    } else {
      child = Text(
        text ?? '',
        style: theme.textTheme.titleLarge?.copyWith(
          color: primaryColor,
        ),
      );
    }

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: defaultPopupBorderRadius,
        ),
        side: BorderSide(color: primaryColor),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
