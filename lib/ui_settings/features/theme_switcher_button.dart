import 'package:flutter/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({required this.settings, super.key});
  final ProjectsNotifier settings;
  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.read<UserNotifier>();
    final themeMode = context.select<UserNotifier, ThemeMode>(
      (final c) => c.user.settings.themeMode,
    );
    return LaSelect<ThemeMode>(
      value: themeMode,
      onChanged: (final value) {
        if (value != null) userNotifier.updateThemeMode(value);
      },
      items: [
        LaSelectItem(value: ThemeMode.system, label: context.l10n.themeSystem),
        LaSelectItem(value: ThemeMode.light, label: context.l10n.themeLight),
        LaSelectItem(value: ThemeMode.dark, label: context.l10n.themeDark),
      ],
    );
  }
}
