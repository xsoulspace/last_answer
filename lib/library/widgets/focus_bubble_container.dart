part of widgets;

class FocusBubbleContainerConsts {
  FocusBubbleContainerConsts._({required final this.context});
  factory FocusBubbleContainerConsts.of(final BuildContext context) =>
      FocusBubbleContainerConsts._(context: context);
  final BuildContext context;
  ThemeData get theme => Theme.of(context);

  Brightness get brightness => theme.brightness;

  Color get defaultFillColor => brightness == Brightness.dark
      ? theme.cardColor.withOpacity(0.2)
      : theme.canvasColor;

  Color get defaultFillFocusColor =>
      brightness == Brightness.dark ? theme.cardColor : theme.cardColor;
}

class FocusBubbleContainer extends HookWidget {
  const FocusBubbleContainer({
    required final this.child,
    final this.constraints,
    final this.padding,
    final this.onUnfocus,
    final this.onFocus,
    final this.fillColor,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  final BoxConstraints? constraints;
  final EdgeInsets? padding;
  final VoidCallback? onUnfocus;
  final VoidCallback? onFocus;
  final Color? fillColor;

  @override
  Widget build(final BuildContext context) {
    final consts = FocusBubbleContainerConsts.of(context);
    final fillColorNotifier = useState(consts.defaultFillColor);
    return Focus(
      onFocusChange: (final hasFocus) {
        if (hasFocus) {
          fillColorNotifier.value = consts.defaultFillFocusColor;
          onFocus?.call();
        } else {
          fillColorNotifier.value = consts.defaultFillColor;
          onUnfocus?.call();
        }
      },
      child: AnimatedContainer(
        decoration: BoxDecoration(
          borderRadius: defaultBorderRadius,
          color: fillColor ?? fillColorNotifier.value,
        ),
        constraints: constraints,
        padding: padding,
        duration: const Duration(milliseconds: 350),
        child: child,
      ),
    );
  }
}
