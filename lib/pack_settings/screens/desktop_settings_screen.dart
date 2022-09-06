import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/features_widgets/general_settings.dart';
import 'package:lastanswer/pack_settings/features_widgets/my_account.dart';
import 'package:lastanswer/pack_settings/features_widgets/settings_navigation.dart';
import 'package:provider/provider.dart';

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
    final routeState = context.watch<RouteState>();
    final pathTemplate = routeState.route.pathTemplate;

    switch (pathTemplate) {
      case NavigationRoutes.subscription:
        child = previousChild.value = const SubscriptionInfo();
        break;
      case NavigationRoutes.profile:
        child = previousChild.value = MyAccount(
          onSignIn: () => context.read<AppRouterController>().toSignIn(),
        );
        break;
      case NavigationRoutes.settings:
      case NavigationRoutes.generalSettings:
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
