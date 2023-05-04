import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/widgets/settings_button.dart';
import 'package:provider/provider.dart';

class SettingsNavigation extends StatelessWidget {
  const SettingsNavigation({
    required this.onSelectRoute,
    super.key,
  });
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final routeState = context.watch<RouteState>();
    final screenLayout = ScreenLayout.of(context);
    final paymentsService = context.watch<PaymentsControllerI>();

    BoolValueChanged<AppRouteName>? effectiveSelectedRouteCheck;
    if (screenLayout.notSmall) {
      effectiveSelectedRouteCheck = routeState.checkIsCurrentRoute;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: screenLayout.small
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      mainAxisSize: screenLayout.small ? MainAxisSize.max : MainAxisSize.min,
      children: [
        SettingsButton(
          routeName: NavigationRoutes.generalSettings,
          fallbackRouteName: NavigationRoutes.settings,
          onSelected: onSelectRoute,
          checkSelected: effectiveSelectedRouteCheck,
          text: screenLayout.small
              ? S.current.generalSettingsFullTitle
              : S.current.generalSettingsShortTitle,
          // TODO(arenukvern): add icon
        ),
        // if (paymentsService.paymentsAccessable)
        SettingsButton(
          routeName: NavigationRoutes.profile,
          onSelected: onSelectRoute,
          checkSelected: routeState.checkIsCurrentRoute,
          text: S.current.myAccount,
          // TODO(arenukvern): add icon
        ),
        if (paymentsService.paymentsAccessable)
          SettingsButton(
            routeName: NavigationRoutes.subscription,
            onSelected: onSelectRoute,
            checkSelected: routeState.checkIsCurrentRoute,
            text: S.current.subscription,
            // TODO(arenukvern): add icon
          ),
        SettingsButton(
          routeName: NavigationRoutes.changelog,
          onSelected: (final _) async {
            await showNotificationDialog(context: context);
          },
          checkSelected: routeState.checkIsCurrentRoute,
          text: S.current.changeLog,
          // TODO(arenukvern): add avatar
        ),
      ],
    );
  }
}
