import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/widgets/buttons/cupertino_icon_button.dart';
import 'package:lastanswer/utils/utils.dart';

class AdaptiveBackButton extends HookWidget {
  const AdaptiveBackButton({
    required final this.onPressed,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();
    if (isDesktop) {
      final theme = Theme.of(context);

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (final _) => hovered.value = true,
        onExit: (final _) => hovered.value = false,
        child: CupertinoIconButton(
          onPressed: onPressed,
          size: 18,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          backgroundColor: hovered.value ? theme.hoverColor : null,
          icon: Icons.arrow_back_ios_new_rounded,
        ),
      );
    }

    return BackButton(onPressed: onPressed);
  }
}
