part of '../widgets.dart';

typedef HoverableWidgetBuilder = Widget Function(
  BuildContext context,
  // ignore: avoid_positional_boolean_parameters
  bool hovered,
);

class HoverableArea extends HookWidget {
  const HoverableArea({
    required this.builder,
    this.clickable = true,
    super.key,
  });
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
