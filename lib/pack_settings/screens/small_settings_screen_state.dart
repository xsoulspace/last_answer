import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_settings/screens/general_settings_screen.dart';
import 'package:lastanswer/pack_settings/screens/my_account_screen.dart';
import 'package:lastanswer/pack_settings/screens/subscription_screen.dart';
import 'package:life_hooks/life_hooks.dart';

SmallSettingsScreenState useSmallSettingsScreenStateState({
  required final RouteState routeState,
  required final ValueChanged<AppRouteName> onSelectRoute,
  required final VoidCallback onBack,
  required final VoidCallback onSignIn,
  required final ScreenLayout screenLayout,
}) =>
    use(
      LifeHook(
        debugLabel: 'SmallSettingsScreenState',
        state: SmallSettingsScreenState(
          routeState: routeState,
          onSignIn: onSignIn,
          screenLayout: screenLayout,
          onSelectRoute: onSelectRoute,
          onBack: onBack,
        ),
      ),
    );

class SmallSettingsScreenState extends LifeState {
  SmallSettingsScreenState({
    required this.routeState,
    required this.onSelectRoute,
    required this.onBack,
    required this.onSignIn,
    required this.screenLayout,
  });
  final RouteState routeState;
  final VoidCallback onSignIn;

  final ValueChanged<AppRouteName> onSelectRoute;
  final VoidCallback onBack;
  final pageController = PageController();
  final chosenPage = ValueNotifier<int>(0);
  final subSettingsPage = ValueNotifier<Widget?>(null);
  final ScreenLayout screenLayout;

  @override
  void initState() {
    pageController.addListener(onPageCahnged);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    pageController
      ..removeListener(onPageCahnged)
      ..dispose();
    chosenPage.dispose();
    subSettingsPage.dispose();
  }

  void onPageCahnged() {
    if (!pageController.hasClients) return;
    final controllerPage = pageController.page?.ceil();
    if (chosenPage.value == controllerPage) return;
    onSelectRoute(NavigationRoutes.settings);
  }

  Future<void> toPage({final int page = 1}) async {
    if (!pageController.hasClients) return;
    chosenPage.value = page;
    await pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linearToEaseOut,
    );
  }

  Future<void> toNavigation() async => toPage(page: 0);

  Future<void> switchToPage() async {
    switch (routeState.route.pathTemplate) {
      case NavigationRoutes.profile:
        subSettingsPage.value = MyAccountScreen(
          onBack: onBack,
          onSignIn: onSignIn,
        );
        await toPage();
        break;
      case NavigationRoutes.generalSettings:
        subSettingsPage.value = GeneralSettingsScreen(onBack: onBack);
        await toPage();
        break;
      case NavigationRoutes.subscription:
        subSettingsPage.value = SubscriptionScreen(onBack: onBack);
        await toPage();
        break;
      default:
        await toNavigation();
    }
  }
}

void useSmallSettingsScreenEffects({
  required final SmallSettingsScreenState state,
}) {
  useEffect(
    () {
      state.switchToPage();

      return null;
    },
    [state.routeState.route],
  );

  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        state.switchToPage();
      });

      return null;
    },
    [state.screenLayout.small],
  );
}
