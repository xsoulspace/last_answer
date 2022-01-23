part of pack_settings;

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = GeneralSettingsStateScope.of(context);
    final screenLayout = ScreenLayout.of(context);

    final leftPadding = screenLayout.small ? 90.0 : 150.0;
    final rightPadding = screenLayout.small ? 0.0 : 90.0;

    return SingleChildScrollView(
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
            child: ThemeSwitcherButton(
              settings: settings,
            ),
          ),
          SettingsListTile(
            title: S.current.language,
            leftPadding: leftPadding,
            rightPadding: rightPadding,
            child: LocaelSwitcherButton(
              settings: settings,
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
            height: 24,
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
    );
  }
}
