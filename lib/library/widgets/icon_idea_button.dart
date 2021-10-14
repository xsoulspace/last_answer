part of widgets;

class IconIdeaButton extends StatelessWidget {
  const IconIdeaButton({
    required final this.onTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onTap;
  @override
  Widget build(final BuildContext context) {
    return SvgIconButton(
      onPressed: onTap,
      svg: Assets.icons.idea,
    );
  }
}
