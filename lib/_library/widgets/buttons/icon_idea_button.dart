import 'package:lastanswer/_library/widgets/buttons/svg_icon_button.dart';
import 'package:lastanswer/common_imports.dart';

class IconIdeaButton extends StatelessWidget {
  const IconIdeaButton({
    this.onTap,
    this.size = 24.0,
    super.key,
  });
  final VoidCallback? onTap;
  final double size;
  @override
  Widget build(final BuildContext context) => SvgIconButton(
        onPressed: onTap,
        iconSize: size,
        svg: Assets.icons.idea,
      );
}

class IconIdea extends StatelessWidget {
  const IconIdea({
    this.size = 24.0,
    super.key,
  });
  final double size;
  @override
  Widget build(final BuildContext context) => Assets.icons.idea.svg(
        height: size,
        width: size,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
      );
}