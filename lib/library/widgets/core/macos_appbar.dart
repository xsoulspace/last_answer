part of widgets;

class LeftPanelMacosAppBar extends AppBar {
  LeftPanelMacosAppBar({
    required final BuildContext context,
    final String title = '',
    super.actions,
    super.key,
  }) : super(
          leadingWidth: 0,
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: title.isNotEmpty
                ? [
                    const TopSafeArea(),
                    const SizedBox(height: 9),
                    SelectableText(
                      title,
                      textAlign: TextAlign.left,
                      style: ThemeDefiner.of(context)
                          .effectiveTheme
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 16),
                    ),
                  ]
                : [],
          ),
        );
}

class BackTextUniversalAppBar extends AppBar {
  BackTextUniversalAppBar({
    required final VoidCallback onBack,
    final ScreenLayout? screenLayout,
    super.actions,
    final String? titleStr,
    final Widget? title,
    super.key,
    final bool useBackButton = false,
    final double? height,
  })  : assert(
          titleStr != null || title != null,
          'Title or title str should not be empty',
        ),
        super(
          toolbarHeight: height ?? (Platform.isMacOS ? 70 : null),
          leading: (screenLayout?.small ?? true)
              ? _AppBarLeading(
                  onBack: onBack,
                  useBackButton: useBackButton,
                )
              : null,
          centerTitle: true,
          title: title ?? Text(titleStr ?? ''),
        );
}

class _AppBarLeading extends StatelessWidget {
  const _AppBarLeading({
    required this.useBackButton,
    required this.onBack,
  });
  final bool useBackButton;
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final backButton = useBackButton
        ? AdaptiveBackButton(onPressed: onBack)
        : CloseButton(onPressed: onBack);
    if (Platform.isMacOS) {
      return Column(
        children: [
          const TopSafeArea(),
          const SizedBox(height: 25),
          backButton,
        ],
      );
    }

    return backButton;
  }
}
