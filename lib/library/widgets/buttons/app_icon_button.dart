import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/core/hoverable_area.dart';

class HoverableButton extends StatelessWidget {
  const HoverableButton({
    required final this.onPressed,
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return HoverableArea(
      builder: (final context, final hovered) => CupertinoButton(
        minSize: 0,
        borderRadius: defaultBorderRadius,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        color: hovered && onPressed != null ? theme.hoverColor : null,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
