part of 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    Widget getItemText(final String text) => Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
        );
    final settings = SettingsStateScope.of(context);
    final languageCode = settings.locale?.languageCode;
    final String effectiveLanguageCode =
        languageCode ?? getLanguageCode(Intl.getCurrentLocale());
    final _initLocale =
        namedLocalesMap[effectiveLanguageCode]?.locale ?? Locales.en;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        onBack: onBack,
        titleStr: S.current.settings,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(18),
        children: [
          ...[
            // Glue the SettingsController to the theme selection
            // DropdownButton.
            //
            // When a user selects a theme from the dropdown list, the
            // SettingsController is updated, which rebuilds the MaterialApp.
            Row(
              children: [
                Text('${S.current.theme}:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<ThemeMode>(
                    // Read the selected themeMode from the controller
                    value: settings.themeMode,
                    // Call the updateThemeMode method any time the user selects
                    // theme.
                    onChanged: settings.updateThemeMode,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: getItemText(S.current.themeSystem),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: getItemText(S.current.themeLight),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: getItemText(S.current.themeDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('${S.current.language}:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<Locale>(
                    // Read the selected themeMode from the controller
                    value: _initLocale,
                    // Call the updateThemeMode method any time the user selects
                    // theme.
                    onChanged: settings.updateLocale,
                    isExpanded: true,
                    items: namedLocalesMap.values
                        .map(
                          (final e) => DropdownMenuItem<Locale>(
                            value: e.locale,
                            key: ValueKey(e.code),
                            child: getItemText(e.name),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            )
            // ** An Example of how to use link **
            // Link(
            //   uri: Uri.parse('/book/0'),
            //   builder: (context, followLink) => TextButton(
            //     onPressed: followLink,
            //     child: const Text('Go directly to /book/0 (Link)'),
            //   ),
            // ),
          ].map(
            (final w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: w,
            ),
          ),
        ],
      ),
    );
  }
}
