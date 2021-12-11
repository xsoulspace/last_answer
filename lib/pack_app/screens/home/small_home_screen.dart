part of pack_app;

class SmallHomeScreen extends StatefulHookWidget {
  const SmallHomeScreen({
    required this.onProjectTap,
    required this.onSettingsTap,
    required this.onInfoTap,
    required this.onCreateIdeaTap,
    required this.onCreateNoteTap,
    required this.onGoHome,
    required this.checkIsProjectActive,
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

    final verticalMenu = HomeVerticalMenu(
      onCreateIdeaTap: widget.onCreateIdeaTap,
      onCreateNoteTap: widget.onCreateNoteTap,
    );

    final projectsList = ProjectsListView(
      checkIsProjectActive: widget.checkIsProjectActive,
      onGoHome: widget.onGoHome,
      onProjectTap: widget.onProjectTap,
      themeDefiner: themeDefiner,
    );

    final body = Scaffold(
      appBar: HomeAppBar.build(
        context: context,
        onInfoTap: widget.onInfoTap,
        onSettingsTap: widget.onSettingsTap,
      ),
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
    );
    return Theme(
      data: effectiveTheme,
      child: body,
    );
  }
}

class HomeVerticalMenu extends StatelessWidget {
  const HomeVerticalMenu({
    required this.onCreateIdeaTap,
    required this.onCreateNoteTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;

  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);
    return ColoredBox(
      color: themeDefiner.useContextTheme
          ? themeDefiner.effectiveTheme.primaryColor.withOpacity(.03)
          : Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _VerticalProjectsBar(
            onIdeaTap: onCreateIdeaTap,
            onNoteTap: onCreateNoteTap,
          ),
          const SizedBox(height: 14),
          const BottomSafeArea(),
        ],
      ),
    );
  }
}

class HomeAppBar {
  HomeAppBar._();
  static PreferredSizeWidget build({
    required final VoidCallback onSettingsTap,
    required final VoidCallback onInfoTap,
    required final BuildContext context,
  }) {
    final greeting = Greeting();
    final themeDefiner = ThemeDefiner.of(context);
    final effectiveTheme = themeDefiner.effectiveTheme;

    if (Platform.isMacOS) {
      return LeftPanelMacosAppBar(
        context: context,
        title: greeting.current,
        actions: [
          IconButton(
            onPressed: onInfoTap,
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: onSettingsTap,
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
          onPressed: onInfoTap,
          icon: const Icon(Icons.info_outline),
        ),
        IconButton(
          onPressed: onSettingsTap,
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
}
