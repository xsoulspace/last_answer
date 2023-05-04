import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/library/widgets/buttons/svg_icon_button.dart';

class IconIdeaButton extends StatelessWidget {
  const IconIdeaButton({
    this.onTap,
    this.size = 24.0,
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
    this.size = 24.0,
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
