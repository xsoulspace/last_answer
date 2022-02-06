part of widgets;

class CupertinoIconButton extends StatelessWidget {
  const CupertinoIconButton({
    required final this.onPressed,
    required final this.icon,
    final this.color,
    final this.backgroundColor,
    final this.padding,
    final this.size,
    final Key? key,
  }) : super(key: key);
  final IconData icon;
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
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
