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
                    const SafeAreaTop(),
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
    final String? titleStr,
    final Widget? title,
    final Key? key,
    final bool useBackButton = false,
  })  : assert(
          titleStr != null || title != null,
          'Title or title str should not be empty',
        ),
        super(
          toolbarHeight: Platform.isMacOS ? 70 : null,
          leading: Platform.isMacOS
              ? Column(
                  children: [
                    const SafeAreaTop(),
                    const SizedBox(height: 25),
                    if (useBackButton)
                      BackButton(onPressed: onBack)
                    else
                      CloseButton(onPressed: onBack),
                  ],
                )
              : useBackButton
                  ? BackButton(onPressed: onBack)
                  : CloseButton(onPressed: onBack),
          centerTitle: true,
          title: title ?? Text(titleStr!),
          key: key,
        );
}
