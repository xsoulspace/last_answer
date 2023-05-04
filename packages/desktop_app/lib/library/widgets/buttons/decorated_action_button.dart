import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lastanswer/library/theme/theme.dart';

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
            borderRadius: defaultPopupBorderRadius,
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
          borderRadius: defaultPopupBorderRadius,
        ),
        primary: surfaceColor,
      ),
      child: child,
    );
  }
}
