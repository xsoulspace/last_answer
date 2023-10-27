part of '../widgets.dart';

class FocusBubbleContainerConsts {
  FocusBubbleContainerConsts._({required this.context});
  factory FocusBubbleContainerConsts.of(final BuildContext context) =>
      FocusBubbleContainerConsts._(context: context);
  final BuildContext context;
  ThemeData get theme => Theme.of(context);

  Brightness get brightness => theme.brightness;

  Color get defaultFillColor => brightness == Brightness.dark
      ? theme.cardColor.withOpacity(0.2)
      : theme.canvasColor;

  Color get defaultFillFocusColor => theme.cardColor;
}

class FocusBubbleContainer extends HookWidget {
  const FocusBubbleContainer({
    required this.child,
    this.constraints,
    this.padding,
    this.onUnfocus,
    this.onFocus,
    this.fillColor,
    this.fillDefaultWithCanvas = false,
    super.key,
  });
  final Widget child;
  final BoxConstraints? constraints;
  final EdgeInsets? padding;
  final VoidCallback? onUnfocus;
  final VoidCallback? onFocus;
  final Color? fillColor;
  final bool fillDefaultWithCanvas;
  @override
  Widget build(final BuildContext context) {
    final consts = FocusBubbleContainerConsts.of(context);
    final theme = Theme.of(context);
    Color getDefaultColor() =>
        fillDefaultWithCanvas ? theme.canvasColor : consts.defaultFillColor;
    final fillColorNotifier = useState(getDefaultColor());
    useValueChanged<ThemeData, void>(theme, (final _, final __) {
      fillColorNotifier.value = getDefaultColor();
    });

    return Focus(
      onFocusChange: (final hasFocus) {
        if (hasFocus) {
          fillColorNotifier.value = consts.defaultFillFocusColor;
          onFocus?.call();
        } else {
          fillColorNotifier.value = fillDefaultWithCanvas
              ? theme.canvasColor
              : consts.defaultFillColor;
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
