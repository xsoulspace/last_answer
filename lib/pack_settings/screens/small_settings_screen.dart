import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_settings/screens/settings_navigation_screen.dart';
import 'package:lastanswer/pack_settings/screens/small_settings_screen_state.dart';

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
    final navigatorController = AppNavigatorController.use(
      routeState: routeState,
      context: context,
      screenLayout: screenLayout,
    );
    final state = useSmallSettingsScreenStateState(
      onSignIn: navigatorController.toSignIn,
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
