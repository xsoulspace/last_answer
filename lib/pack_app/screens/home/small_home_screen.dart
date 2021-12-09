part of pack_app;

class SmallHomeScreen extends StatefulHookWidget {
  const SmallHomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    required final this.onCreateNoteTap,
    required final this.onGoHome,
    required final this.checkIsProjectActive,
    final this.verticalMenuAlignment = Alignment.bottomLeft,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final Alignment verticalMenuAlignment;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;

  @override
  _SmallHomeScreenState createState() => _SmallHomeScreenState();
}

class _SmallHomeScreenState extends State<SmallHomeScreen> {
  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);
    final effectiveTheme = themeDefiner.effectiveTheme;

    final verticalMenu = ColoredBox(
      color: themeDefiner.useContextTheme
          ? effectiveTheme.primaryColor.withOpacity(.03)
          : Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _VerticalProjectsBar(
            onIdeaTap: widget.onCreateIdeaTap,
            onNoteTap: widget.onCreateNoteTap,
          ),
          const SizedBox(height: 14),
          const BottomSafeArea(),
        ],
      ),
    );

    final projectsList = ProjectsListView(
      checkIsProjectActive: widget.checkIsProjectActive,
      onGoHome: widget.onGoHome,
      onProjectTap: widget.onProjectTap,
      themeDefiner: themeDefiner,
    );

    final greeting = Greeting();

    AppBar createAppBar() {
      if (Platform.isMacOS) {
        return LeftPanelMacosAppBar(
          context: context,
          title: greeting.current,
          actions: [
            IconButton(
              onPressed: widget.onInfoTap,
              icon: const Icon(Icons.info_outline),
            ),
            IconButton(
              onPressed: widget.onSettingsTap,
              icon: const Icon(Icons.settings),
            ),
          ]
              .map(
                (final child) => Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: child,
                ),
              )
              .toList(),
        );
      }
      return AppBar(
        // TODO(arenukvern): make popup with translation for native language
        title: SelectableText(
          greeting.current,
          style: effectiveTheme.textTheme.headline2,
        ),
        actions: [
          IconButton(
            onPressed: widget.onInfoTap,
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: widget.onSettingsTap,
            icon: const Icon(Icons.settings),
          ),
        ]
            .map(
              (final child) => Padding(
                padding: const EdgeInsets.only(right: 18),
                child: child,
              ),
            )
            .toList(),
      );
    }

    return Theme(
      data: effectiveTheme,
      child: Scaffold(
        appBar: createAppBar(),
        body: Row(
          children: [
            const SizedBox(height: 2),
            if (widget.verticalMenuAlignment == Alignment.bottomLeft)
              verticalMenu,
            projectsList,
            if (widget.verticalMenuAlignment == Alignment.bottomRight)
              verticalMenu,
          ],
        ),
      ),
    );
  }
}
