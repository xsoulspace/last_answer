part of widgets;

class ButtonPopup extends StatelessWidget {
  const ButtonPopup({
    required final this.children,
    final Key? key,
  }) : super(key: key);
  final List<Widget> children;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.cleanBlack
        : AppColors.grey4;
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
        height: 320,
        width: 250,
        child: Stack(
          children: [
            ColoredBox(
              color: theme.canvasColor.withOpacity(0.3),
              child: const SizedBox.expand(),
            ).frosted(
              blur: theme.brightness == Brightness.dark ? 10 : 7,
              frostOpacity: 0.1,
              frostColor: theme.brightness == Brightness.dark
                  ? AppColors.cleanBlack
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
