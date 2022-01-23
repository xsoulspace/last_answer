part of pack_settings;

class SmallSettingsScreen extends StatefulWidget {
  const SmallSettingsScreen({
    required this.onSelectRoute,
    required this.onBack,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<AppRouteName> onSelectRoute;
  final VoidCallback onBack;

  @override
  State<SmallSettingsScreen> createState() => _SmallSettingsScreenState();
}

class _SmallSettingsScreenState extends State<SmallSettingsScreen> {
  final _navigatorKey = GlobalKey();
  @override
  Widget build(final BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    return Navigator(
      key: _navigatorKey,
      // onPopPage: ,
      pages: [
        if (pathTemplate == AppRoutesName.generalSettings ||
            pathTemplate == AppRoutesName.settings)
          MaterialPage(
            key: NavigatorValueKeys.generalSettings,
            child: GeneralSettingsScreen(onBack: widget.onBack),
          )
        else
          throw UnimplementedError()
      ],
    );
  }
}
