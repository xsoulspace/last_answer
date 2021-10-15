part of 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final settings = SettingsStateScope.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: onBack,
        ),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (final context, final snapshot) {
          final info = snapshot.data;
          final version = 'App version: ${info?.version}, '
              'build: ${info?.buildNumber}';
          return ListView(
            children: [
              ...[
                SelectableText(version),
                // Glue the SettingsController to the theme selection
                // DropdownButton.
                //
                // When a user selects a theme from the dropdown list, the
                // SettingsController is updated, which rebuilds the MaterialApp.
                DropdownButton<ThemeMode>(
                  // Read the selected themeMode from the controller
                  value: settings.themeMode,
                  // Call the updateThemeMode method any time the user selects
                  // theme.
                  onChanged: settings.updateThemeMode,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    )
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
          );
        },
      ),
    );
  }
}
