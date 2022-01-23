part of pack_settings;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required final this.onBack,
    required this.onSelectRoute,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenLayout = ScreenLayout.of(context);

    final child = screenLayout.small
        ? const SmallSettingsScreen()
        : DesktopSettingsScreen(
            onBack: onBack,
            onSelectRoute: onSelectRoute,
          );

    return Scaffold(
      backgroundColor: theme.canvasColor,
      body: child,
    );
  }
}

class DesktopSettingsScreen extends StatelessWidget {
  const DesktopSettingsScreen({
    required this.onSelectRoute,
    required this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 50,
          child: AdaptiveBackButton(
            onPressed: onBack,
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: ScreenLayout.maxSmallWidth,
              maxWidth: ScreenLayout.maxMediumWidth,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SettingsButton(
                        routeName: AppRoutesName.profile,
                        fallbackRouteName: AppRoutesName.settings,
                        onSelected: onSelectRoute,
                        checkSelected: routeState.checkIsCurrentRoute,
                        text: 'My account',
                        // TODO(arenukvern): add avatar
                      ),
                      SettingsButton(
                        routeName: AppRoutesName.generalSettings,
                        onSelected: onSelectRoute,
                        checkSelected: routeState.checkIsCurrentRoute,
                        text: 'General',
                        // TODO(arenukvern): add avatar
                      ),
                      SettingsButton(
                        routeName: AppRoutesName.subscription,
                        onSelected: onSelectRoute,
                        checkSelected: routeState.checkIsCurrentRoute,
                        text: 'Subscription',
                        // TODO(arenukvern): add avatar
                      ),
                      SettingsButton(
                        routeName: AppRoutesName.changelog,
                        onSelected: onSelectRoute,
                        checkSelected: routeState.checkIsCurrentRoute,
                        text: 'Changelog',
                        // TODO(arenukvern): add avatar
                      ),
                    ],
                  ),
                ),
                // GeneralSettingsScreen(onBack: onBack),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SmallSettingsScreen extends StatelessWidget {
  const SmallSettingsScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Container();
  }
}
