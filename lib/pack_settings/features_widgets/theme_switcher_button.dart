import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/pack_settings/widgets/settings_text.dart';

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({
    required this.settings,
    super.key,
  });
  final ProjectsNotifier settings;
  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.read<UserNotifier>();
    final themeMode = context.select<UserNotifier, ThemeMode>(
      (final c) => c.user.settings.themeMode,
    );
    return DropdownButton<ThemeMode>(
      // Read the selected themeMode from the controller
      value: themeMode,
      // Call the updateThemeMode method any time the user selects
      // theme.
      onChanged: userNotifier.updateThemeMode,
      isExpanded: true,
      items: [
        DropdownMenuItem(
          key: const ValueKey(ThemeMode.system),
          value: ThemeMode.system,
          child: SettingsText(text: context.l10n.themeSystem),
        ),
        DropdownMenuItem(
          key: const ValueKey(ThemeMode.light),
          value: ThemeMode.light,
          child: SettingsText(text: context.l10n.themeLight),
        ),
        DropdownMenuItem(
          key: const ValueKey(ThemeMode.dark),
          value: ThemeMode.dark,
          child: SettingsText(text: context.l10n.themeDark),
        ),
      ],
    );
  }
}
