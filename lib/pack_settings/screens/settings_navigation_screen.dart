part of pack_settings;

class SettingsNavigationScreen extends StatelessWidget {
  const SettingsNavigationScreen({
    required this.onBack,
    required this.onSelectRoute,
    super.key,
  });
  final VoidCallback onBack;
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        leading: CupertinoCloseButton(onPressed: onBack),
        title: Text(S.current.settings),
      ),
      body: SettingsNavigation(
        onSelectRoute: onSelectRoute,
      ),
    );
  }
}
