import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_settings/screens/desktop_settings_screen.dart';
import 'package:lastanswer/pack_settings/screens/small_settings_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    void onBack() => context.read<AppRouterController>().toHome();
    void onSelectRoute(final AppRouteName route) =>
        context.read<AppRouterController>().to(route);
    final child = screenLayout.small
        ? SmallSettingsScreen(
            onBack: onBack,
            onSelectRoute: onSelectRoute,
          )
        : DesktopSettingsScreen(
            onBack: onBack,
            onSelectRoute: onSelectRoute,
          );

    return child;
  }
}
