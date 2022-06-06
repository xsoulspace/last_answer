part of widgets;

Future<void> showFrostedDialog({
  required final BuildContext context,
  required final WidgetBuilder builder,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  await showDialog(
    context: context,
    useRootNavigator: true,
    barrierColor: isDark
        ? AppColors.black.withOpacity(0.8)
        : AppColors.cleanWhite.withOpacity(0.6),
    useSafeArea: false,
    barrierDismissible: true,
    builder: (final context) {
      return FrostedDialog(
        content: builder(context),
      );
    },
  );
}

class FrostedDialog extends StatelessWidget {
  const FrostedDialog({
    required this.content,
    final Key? key,
  }) : super(key: key);
  final Widget content;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final screenLayout = ScreenLayout.of(context);

    final double width = screenLayout.small
        ? size.width
        : math.min(
            size.width * 0.6,
            600,
          );
    final double height = screenLayout.small
        ? size.height
        : math.min(
            size.height * 0.85,
            600,
          );
    final backgroundColor = isDark ? AppColors.black : AppColors.cleanWhite;
    final shape = RoundedRectangleBorder(
      side: isDark
          ? const BorderSide(
              color: AppColors.grey1,
            )
          : BorderSide.none,
      borderRadius: defaultPopupBorderRadius,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: screenLayout.small ? EdgeInsets.zero : null,
      shape: screenLayout.small ? null : shape,
      elevation: 14,
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: defaultPopupBorderRadius,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: backgroundColor,
                    // width: 24,
                  ),
                  vertical: BorderSide(
                    color: backgroundColor,
                    // width: 12,
                  ),
                ),
              ),
              child: const SizedBox.expand(),
            ).blurred(
              borderRadius: defaultPopupBorderRadius,
              colorOpacity: isDark ? 0.7 : 0.88,
              blurColor: backgroundColor,
              blur: isDark ? 54 : 32,
            ),
            Material(
              type: MaterialType.transparency,
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

class FrostedDialogContent extends StatelessWidget {
  const FrostedDialogContent({
    required this.title,
    required this.content,
    this.onWillPop,
    this.onClose,
    this.leftAction,
    this.isCloseButtonVisible = true,
    final Key? key,
  }) : super(key: key);
  final bool isCloseButtonVisible;
  final ValueChanged<BuildContext>? onClose;
  final WillPopCallback? onWillPop;
  final String title;
  final Widget content;
  final Widget? leftAction;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenLayout = ScreenLayout.of(context);
    void close() {
      Navigator.of(context, rootNavigator: true).pop();
      onClose?.call(context);
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: defaultPopupBorderRadius,
        ),
        child: Column(
          children: [
            if (screenLayout.small) const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: Stack(
                children: [
                  if (isCloseButtonVisible)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: CloseButton(
                          onPressed: close,
                        ),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: SelectableText(
                        title,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: content,
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  if (leftAction != null) leftAction!,
                  const Spacer(),
                  TextButton(
                    onPressed: close,
                    child: Text(
                      S.current.close.sentenceCase,
                      style: textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ),
            const BottomSafeArea(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
