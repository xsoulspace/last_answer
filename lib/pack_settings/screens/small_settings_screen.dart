part of pack_settings;

class SmallSettingsScreen extends HookWidget {
  const SmallSettingsScreen({
    required this.onSelectRoute,
    required this.onBack,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<AppRouteName> onSelectRoute;
  final VoidCallback onBack;

  @override
  Widget build(final BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final screenLayout = ScreenLayout.of(context);
    final state = useSmallSettingsScreenStateState(
      onBack: onBack,
      onSelectRoute: onSelectRoute,
      routeState: routeState,
      screenLayout: screenLayout,
    );
    useSmallSettingsScreenEffects(state: state);

    final subPage = state.subSettingsPage.value;

    return PageView(
      physics: const SpeedyPageViewScrollPhysics(),
      controller: state.pageController,
      children: [
        SettingsNavigationScreen(
          onBack: onBack,
          onSelectRoute: onSelectRoute,
        ),
        if (subPage != null) subPage,
      ],
    );
  }
}

class SpeedyPageViewScrollPhysics extends ScrollPhysics {
  const SpeedyPageViewScrollPhysics({final ScrollPhysics? parent})
      : super(parent: parent);

  @override
  SpeedyPageViewScrollPhysics applyTo(final ScrollPhysics? ancestor) {
    return SpeedyPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
