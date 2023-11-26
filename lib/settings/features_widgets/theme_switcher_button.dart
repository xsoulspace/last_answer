import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/widgets/question_dropdown.dart';

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
    return DropdownMenu<ThemeMode>(
      menuStyle: defaultDropdownMenuStyle,
      textStyle: context.textTheme.bodyMedium,
      inputDecorationTheme: defaultDropdownMenuInputTheme,
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: ThemeMode.system,
          label: context.l10n.themeSystem,
        ),
        DropdownMenuEntry(
          value: ThemeMode.light,
          label: context.l10n.themeLight,
        ),
        DropdownMenuEntry(
          value: ThemeMode.dark,
          label: context.l10n.themeDark,
        ),
      ],
      initialSelection: themeMode,
      onSelected: userNotifier.updateThemeMode,
    );
  }
}
