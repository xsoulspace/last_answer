import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:life_hooks/life_hooks.dart';

class CupertinoIconButton extends StatelessWidget {
  const CupertinoIconButton({
    required this.onPressed,
    this.icon,
    this.svg,
    this.color,
    this.backgroundColor,
    this.padding,
    this.size,
    final Key? key,
  }) : super(key: key);
  final IconData? icon;
  final SvgGenImage? svg;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? size;
  @override
  Widget build(final BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      borderRadius: defaultBorderRadius,
      padding: padding ?? EdgeInsets.zero,
      color: backgroundColor,
      onPressed: onPressed,
      child: svg?.svg(
            color: color,
            height: size,
            width: size,
          ) ??
          Icon(
            icon,
            color: color,
            size: size,
          ),
    );
  }
}

class CupertinoActionIconButton extends HookWidget {
  const CupertinoActionIconButton({
    required this.onPressed,
    this.icon,
    this.svg,
    this.color,
    this.backgroundColor,
    this.padding,
    this.size,
    final Key? key,
  }) : super(key: key);
  final IconData? icon;
  final SvgGenImage? svg;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? size;
  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();
    final theme = Theme.of(context);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (final value) => hovered.value = value,
      child: CupertinoIconButton(
        onPressed: onPressed,
        color: theme.colorScheme.onPrimary,
        size: size ?? 18,
        backgroundColor: hovered.value ? theme.hoverColor : null,
        padding: padding ??
            const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 10,
            ),
        icon: icon,
      ),
    );
  }
}
