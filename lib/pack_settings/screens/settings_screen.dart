import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_settings/screens/desktop_settings_screen.dart';
import 'package:lastanswer/pack_settings/screens/small_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);

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
