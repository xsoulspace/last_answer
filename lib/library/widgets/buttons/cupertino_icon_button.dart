part of widgets;

class CupertinoIconButton extends StatelessWidget {
  const CupertinoIconButton({
    required final this.onPressed,
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
