import 'package:flutter/cupertino.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class HoverableButton extends StatelessWidget {
  const HoverableButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    super.key,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  @override
  Widget build(final BuildContext context) {
    final theme = context.theme;
    final primaryColor = theme.colorScheme.primary;

    return HoverableArea(
      builder: (final context, final hovered) => CupertinoButton(
        minSize: 0,
        borderRadius: defaultBorderRadius,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        color: hovered && onPressed != null ? theme.hoverColor : null,
        onPressed: isLoading ? () {} : onPressed,
        // TODO(arenukvern): add loading icon,
        child: IconTheme.merge(
          data: IconThemeData(color: primaryColor),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: primaryColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
