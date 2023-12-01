import 'package:lastanswer/_library/widgets/buttons/svg_icon_button.dart';
import 'package:lastanswer/common_imports.dart';

class IconIdeaButton extends StatelessWidget {
  const IconIdeaButton({
    this.onTap,
    this.color,
    this.size = 24.0,
    super.key,
  });
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  @override
  Widget build(final BuildContext context) => SvgIconButton(
        onPressed: onTap,
        iconSize: size,
        color: color,
        svg: Assets.icons.idea,
      );
}

class IconIdea extends StatelessWidget {
  const IconIdea({
    this.size = 24.0,
    this.color,
    super.key,
  });
  final double size;
  final Color? color;
  @override
  Widget build(final BuildContext context) => Assets.icons.idea.svg(
        height: size,
        width: size,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      );
}
