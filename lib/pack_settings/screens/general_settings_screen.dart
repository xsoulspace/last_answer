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

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenLayout = ScreenLayout.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        screenLayout: screenLayout,
        onBack: onBack,
        titleStr: S.current.settings,
      ),
      body: const GeneralSettings(),
    );
  }
}
