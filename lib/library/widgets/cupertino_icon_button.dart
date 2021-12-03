part of widgets;

class CupertinoIconButton extends StatelessWidget {
  const CupertinoIconButton({
    required final this.onPressed,
    required final this.icon,
    final this.color,
    final Key? key,
  }) : super(key: key);
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  @override
  Widget build(final BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}
