part of widgets;

class LeftPanelMacosAppBar extends AppBar {
  LeftPanelMacosAppBar({
    required final BuildContext context,
    final String title = '',
    final List<Widget>? actions,
    final Key? key,
  }) : super(
          actions: actions,
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
                          .subtitle1
                          ?.copyWith(fontSize: 16),
                    ),
                  ]
                : [],
          ),
          key: key,
        );
}

class BackTextUniversalAppBar extends AppBar {
  BackTextUniversalAppBar({
    required final VoidCallback onBack,
    final ScreenLayout? screenLayout,
    final String? titleStr,
    final Widget? title,
    final Key? key,
    final bool useBackButton = false,
    final double? height,
  })  : assert(
          titleStr != null || title != null,
          'Title or title str should not be empty',
        ),
        super(
          toolbarHeight: height ?? (Platform.isMacOS ? 70 : null),
          leading: (screenLayout?.small ?? true)
              ? Platform.isMacOS
                  ? Column(
                      children: [
                        const TopSafeArea(),
                        const SizedBox(height: 25),
                        if (useBackButton)
                          AdaptiveBackButton(onPressed: onBack)
                        else
                          CloseButton(onPressed: onBack),
                      ],
                    )
                  : useBackButton
                      ? AdaptiveBackButton(onPressed: onBack)
                      : CloseButton(onPressed: onBack)
              : null,
          centerTitle: true,
          title: title ?? Text(titleStr!),
          key: key,
        );
}
