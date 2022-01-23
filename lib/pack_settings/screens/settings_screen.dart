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
    final screenLayout = ScreenLayout.of(context);

    return Stack(
      children: [
        Positioned(
          top: 70,
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SettingsButton(
                      routeName: AppRoutesName.generalSettings,
                      fallbackRouteName: AppRoutesName.settings,
                      onSelected: onSelectRoute,
                      checkSelected: routeState.checkIsCurrentRoute,
                      text: 'General',
                      // TODO(arenukvern): add avatar
                    ),
                    SettingsButton(
                      routeName: AppRoutesName.profile,
                      onSelected: onSelectRoute,
                      checkSelected: routeState.checkIsCurrentRoute,
                      text: 'My account',
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
                      text: 'Change Log',
                      // TODO(arenukvern): add avatar
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  child: SizedBox(
                    width: screenLayout.large ? 85 : 15,
                  ),
                ),
                const DesktopSettingsNavigator(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 100),
                  child: SizedBox(
                    width: screenLayout.large ? 180 : 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopSettingsNavigator extends StatelessWidget {
  const DesktopSettingsNavigator({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenLayout = ScreenLayout.of(context);

    Widget child;
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;
    switch (pathTemplate) {
      case AppRoutesName.settings:
      case AppRoutesName.generalSettings:
      default:
        child = const GeneralSettings(
          padding: EdgeInsets.only(left: 18, right: 48, top: 64, bottom: 64),
        );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: defaultPopupBorderRadius,
        ),
        child: SizedBox(
          width: math.min(
            screenLayout.large ? 500 : 450,
            screenWidth / 1.7,
          ),
          child: child,
        ),
      ),
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
