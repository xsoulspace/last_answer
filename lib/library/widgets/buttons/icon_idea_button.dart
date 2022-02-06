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

class IconIdea extends StatelessWidget {
  const IconIdea({
    final this.size = 24.0,
    final Key? key,
  }) : super(key: key);
  final double size;
  @override
  Widget build(final BuildContext context) {
    return Assets.icons.idea.svg(
      height: size,
      width: size,
      color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.5),
    );
  }
}