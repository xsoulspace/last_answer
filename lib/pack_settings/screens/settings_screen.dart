part of pack_settings;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onBack,
    required this.onSelectRoute,
    super.key,
  });
  final VoidCallback onBack;
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);

    final child = screenLayout.small
        ? SmallSettingsScreen(
            onBack: onBack,
            onSelectRoute: onSelectRoute,
          )
        : DesktopSettingsScreen(
            onBack: onBack,
            onSelectRoute: onSelectRoute,
          );

    return child;
  }
}
