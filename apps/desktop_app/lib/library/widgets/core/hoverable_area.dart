import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:life_hooks/life_hooks.dart';

typedef HoverableWidgetBuilder = Widget Function(
  BuildContext context,
  bool hovered,
);

class HoverableArea extends HookWidget {
  const HoverableArea({
    required this.builder,
    this.clickable = true,
    final Key? key,
  }) : super(key: key);
  final HoverableWidgetBuilder builder;
  final bool clickable;

  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();

    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (final _) => hovered.value = true,
      onExit: (final _) => hovered.value = false,
      child: builder(context, hovered.value),
    );
  }
}
