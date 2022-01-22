part of pack_settings;

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
          value: ThemeMode.system,
          child: SettingsScreenItem(text: S.current.themeSystem),
        ),
        DropdownMenuItem(
          value: ThemeMode.light,
          child: SettingsScreenItem(text: S.current.themeLight),
        ),
        DropdownMenuItem(
          value: ThemeMode.dark,
          child: SettingsScreenItem(text: S.current.themeDark),
        ),
      ],
    );
  }
}
