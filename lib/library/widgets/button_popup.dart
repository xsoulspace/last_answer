part of widgets;

class ButtonPopup extends StatelessWidget {
  const ButtonPopup({
    required final this.children,
    final this.height,
    final this.hideBorder = false,
    final Key? key,
  }) : super(key: key);
  final List<Widget> children;
  final double? height;
  final bool hideBorder;
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
        height: height ?? 320,
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}
