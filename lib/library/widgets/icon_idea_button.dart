part of widgets;

class IconIdeaButton extends StatelessWidget {
  const IconIdeaButton({
    final this.onTap,
    final this.size = 24.0,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onTap;
  final double size;
  @override
  Widget build(final BuildContext context) {
    return SvgIconButton(
      onPressed: onTap,
      iconSize: size,
      svg: Assets.icons.idea,
    );
  }
}
