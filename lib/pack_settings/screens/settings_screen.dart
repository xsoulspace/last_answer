part of pack_settings;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = GeneralSettingsStateScope.of(context);
    final languageCode = settings.locale?.languageCode;
    final String effectiveLanguageCode =
        languageCode ?? getLanguageCode(intl.Intl.getCurrentLocale());
    final _initLocale =
        namedLocalesMap[effectiveLanguageCode]?.locale ?? Locales.en;
    final screenLayout = ScreenLayout.of(context);

    return Scaffold(backgroundColor: theme.canvasColor, body: Row());
  }
}
