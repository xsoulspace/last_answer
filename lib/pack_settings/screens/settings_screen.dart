part of pack_settings;

class SettingsScreenItem extends StatelessWidget {
  const SettingsScreenItem({
    required this.text,
    final Key? key,
  }) : super(key: key);
  final String text;
  @override
  Widget build(final BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyText2,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    final settings = SettingsStateScope.of(context);
    final languageCode = settings.locale?.languageCode;
    final String effectiveLanguageCode =
        languageCode ?? getLanguageCode(intl.Intl.getCurrentLocale());
    final _initLocale =
        namedLocalesMap[effectiveLanguageCode]?.locale ?? Locales.en;
    final screenLayout = ScreenLayout.of(context);
    final leftPadding = screenLayout.small ? 90.0 : 150.0;
    final rightPadding = screenLayout.small ? 0.0 : 90.0;

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        screenLayout: screenLayout,
        onBack: onBack,
        titleStr: S.current.settings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Glue the SettingsController to the theme selection
            // DropdownButton.
            //
            // When a user selects a theme from the dropdown list, the
            // SettingsController is updated, which rebuilds the MaterialApp.
            SettingsListTile(
              title: S.current.theme,
              leftPadding: leftPadding,
              rightPadding: rightPadding,
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
              ),
            ),
            SettingsListTile(
              title: S.current.language,
              leftPadding: leftPadding,
              rightPadding: rightPadding,
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
                        child: SettingsScreenItem(text: e.name),
                      ),
                    )
                    .toList(),
              ),
            ),
            SettingsListTile(
              title: S.current.projectsDirection,
              leftPadding: leftPadding,
              rightPadding: rightPadding,
              child: ProjectsDirectionSwitch(
                settings: settings,
              ),
            ),

            Divider(
              color: theme.highlightColor,
              height: 20,
              endIndent: 10,
              indent: 10,
            ),
            Text(S.current.note),
            const SizedBox(height: 24),
            SettingsListTile(
              title: S.current.charactersLimit,
              crossAxisAlignment: CrossAxisAlignment.start,
              leftPadding: leftPadding,
              rightPadding: rightPadding,
              description: S.current.charactersLimitForNewNotesDesription,
              child: const CharactersLimitSetting(),
            ),

            // ** An Example of how to use link **
            // Link(
            //   uri: Uri.parse('/book/0'),
            //   builder: (context, followLink) => TextButton(
            //     onPressed: followLink,
            //     child: const Text('Go directly to /book/0 (Link)'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}