part of widgets;

class ButtonPopup extends StatelessWidget {
  const ButtonPopup({
    final this.children = const [],
    final this.child,
    final this.height = 320,
    final this.hideBorder = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    final Key? key,
  })  : assert(
          children != const [] || child != null,
          'Please provide children or child',
        ),
        super(key: key);
  final List<Widget> children;
  final Widget? child;
  final double height;
  final bool hideBorder;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    Color borderColor;
    if (hideBorder) {
      borderColor = Colors.transparent;
    } else if (theme.brightness == Brightness.dark) {
      borderColor = AppColors.cleanBlack;
    } else {
      borderColor = AppColors.grey4;
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: defaultBorderRadius,
        side: BorderSide(
          color: borderColor,
        ),
      ),
      child: SizedBox(
        height: height,
        width: 250,
        child: Stack(
          children: [
            ColoredBox(
              color: theme.canvasColor.withOpacity(0),
              child: const SizedBox.expand(),
            ).frosted(
              blur: theme.brightness == Brightness.dark ? 15 : 12,
              frostOpacity: 0.1,
              frostColor: theme.brightness == Brightness.dark
                  ? AppColors.black
                  : AppColors.white,
            ),
            if (child != null)
              child!
            else
              Column(
                mainAxisSize: mainAxisSize,
                crossAxisAlignment: crossAxisAlignment,
                mainAxisAlignment: mainAxisAlignment,
                children: children,
              ),
          ],
        ),
      ),
    );
  }
}
