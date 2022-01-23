part of pack_settings;

class SettingsNavigationScreen extends StatelessWidget {
  const SettingsNavigationScreen({
    required final this.onBack,
    required this.onSelectRoute,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ValueChanged<AppRouteName> onSelectRoute;

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
      body: SettingsNavigation(
        onSelectRoute: onSelectRoute,
      ),
    );
  }
}
