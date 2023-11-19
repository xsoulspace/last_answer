import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/pack_settings/widgets/settings_text.dart';

class LocaleSwitcherButton extends StatelessWidget {
  const LocaleSwitcherButton({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.read<UserNotifier>();
    final locale =
        context.select<UserNotifier, Locale>((final c) => c.locale.value);
    final language = Languages.values.byName(locale.languageCode);
    final initLocale = namedLocalesMap[language]?.locale ?? Locales.en;

    return DropdownButton<Locale>(
      // Read the selected themeMode from the controller
      value: initLocale,
      // Call the updateThemeMode method any time the user selects
      // theme.
      onChanged: userNotifier.updateLocale,
      isExpanded: true,
      items: namedLocalesMap.values
          .map(
            (final e) => DropdownMenuItem<Locale>(
              value: e.locale,
              key: ValueKey(e.code),
              child: SettingsText(text: e.name),
            ),
          )
          .toList(),
    );
  }
}
