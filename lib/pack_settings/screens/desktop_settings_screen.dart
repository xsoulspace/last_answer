part of pack_settings;

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
    final screenLayout = ScreenLayout.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Stack(
        children: [
          Positioned(
            top: 70,
            left: 50,
            child: CupertinoCloseButton(onPressed: onBack),
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
                  SettingsNavigation(
                    onSelectRoute: onSelectRoute,
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
      ),
    );
  }
}

class DesktopSettingsNavigator extends HookWidget {
  const DesktopSettingsNavigator({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenLayout = ScreenLayout.of(context);
    final previousChild = useState<Widget>(const SizedBox());
    Widget child;
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    final navigatorController = AppNavigatorController.use(
      routeState: routeState,
      context: context,
      screenLayout: screenLayout,
    );
    switch (pathTemplate) {
      case AppRoutesName.subscription:
        child = previousChild.value = const SubscriptionInfo();
        break;
      case AppRoutesName.profile:
        child = previousChild.value = MyAccount(
          onSignIn: navigatorController.goSignIn,
        );
        break;
      case AppRoutesName.settings:
      case AppRoutesName.generalSettings:
        child = previousChild.value = const GeneralSettings(
          padding: EdgeInsets.only(left: 18, right: 48, top: 64, bottom: 64),
        );
        break;
      default:
        child = previousChild.value;
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
