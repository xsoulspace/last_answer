import 'package:flutter/material.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/pack_settings/abstract/general_settings_controller.dart';
import 'package:lastanswer/pack_settings/widgets/settings_text.dart';

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({
    required this.settings,
    final Key? key,
  }) : super(key: key);
  final GeneralSettingsController settings;
  @override
  Widget build(final BuildContext context) {
    return DropdownButton<ThemeMode>(
      // Read the selected themeMode from the controller
      value: settings.themeMode,
      // Call the updateThemeMode method any time the user selects
      // theme.
      onChanged: settings.updateThemeMode,
      isExpanded: true,
      items: [
        DropdownMenuItem(
          key: const ValueKey(ThemeMode.system),
          value: ThemeMode.system,
          child: SettingsText(text: S.current.themeSystem),
        ),
        DropdownMenuItem(
          key: const ValueKey(ThemeMode.light),
          value: ThemeMode.light,
          child: SettingsText(text: S.current.themeLight),
        ),
        DropdownMenuItem(
          key: const ValueKey(ThemeMode.dark),
          value: ThemeMode.dark,
          child: SettingsText(text: S.current.themeDark),
        ),
      ],
    );
  }
}
