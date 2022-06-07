import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_settings/abstract/general_settings_controller.dart';
import 'package:lastanswer/pack_settings/widgets/settings_text.dart';

class LocaleSwitcherButton extends StatelessWidget {
  const LocaleSwitcherButton({
    required this.settings,
    final Key? key,
  }) : super(key: key);
  final GeneralSettingsController settings;

  @override
  Widget build(final BuildContext context) {
    final languageCode = settings.locale?.languageCode;
    final String effectiveLanguageCode =
        languageCode ?? getLanguageCode(intl.Intl.getCurrentLocale());
    final initLocale =
        namedLocalesMap[effectiveLanguageCode]?.locale ?? Locales.en;

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
