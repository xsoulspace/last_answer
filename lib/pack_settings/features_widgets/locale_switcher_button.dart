import 'package:lastanswer/common_imports.dart';

class LocaleSwitcherButton extends StatelessWidget {
  const LocaleSwitcherButton({
    required this.settings,
    super.key,
  });
  final GeneralSettingsController settings;

  @override
  Widget build(final BuildContext context) {
    final languageCode = settings.locale?.languageCode;
    final String effectiveLanguageCode =
        languageCode ?? getLanguageCode(intl.Intl.getCurrentLocale());
    final language = Languages.values.byName(effectiveLanguageCode);
    final initLocale = namedLocalesMap[language]?.locale ?? Locales.en;

    return DropdownButton<Locale>(
      // Read the selected themeMode from the controller
      value: initLocale,
      // Call the updateThemeMode method any time the user selects
      // theme.
      onChanged: settings.updateLocale,
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
