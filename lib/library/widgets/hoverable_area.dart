part of widgets;

typedef HoverableWidgetBuilder = Widget Function(
  BuildContext context,
  bool hovered,
);

class HoverableArea extends HookWidget {
  const HoverableArea({
    required this.builder,
    final Key? key,
  }) : super(key: key);
  final HoverableWidgetBuilder builder;
  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (final _) => hovered.value = true,
      onExit: (final _) => hovered.value = false,
      child: builder(context, hovered.value),
    );
  }
}
