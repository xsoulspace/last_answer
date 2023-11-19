import 'package:flutter/cupertino.dart';
import 'package:lastanswer/common_imports.dart';

class CupertinoIconButton extends StatelessWidget {
  const CupertinoIconButton({
    required this.onPressed,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.padding,
    this.size,
    super.key,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? size;
  @override
  Widget build(final BuildContext context) => CupertinoButton(
        minSize: 0,
        borderRadius: defaultBorderRadius,
        padding: padding ?? EdgeInsets.zero,
        color: backgroundColor,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      );
}
