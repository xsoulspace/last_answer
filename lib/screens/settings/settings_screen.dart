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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: onBack,
        ),
        title: Text(S.current.settings),
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
                        child: getItemText('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: getItemText('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: getItemText('Dark'),
                      )
                    ],
                  ),
                ),
              ],
            ),

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
