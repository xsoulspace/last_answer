part of pack_app;

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService with SharedPreferencesUtil {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    final theme = await getString(SharedPreferencesKeys.theme);
    final index = int.tryParse(theme);
    if (index == null) return ThemeMode.system;
    if (index > ThemeMode.values.length || index < 0) return ThemeMode.system;

    return ThemeMode.values[index];
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> setThemeMode(final ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
    await setString(SharedPreferencesKeys.theme, theme.index.toString());
  }

  Future<Locale> locale() async {
    final languageCode = await getString(SharedPreferencesKeys.locale);
    try {
      if (languageCode.isEmpty) return Locales.en;

      return Locale.fromSubtags(languageCode: languageCode);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return Locales.en;
    }
  }

  Future<void> setLocale(final Locale locale) async {
    await setString(SharedPreferencesKeys.locale, locale.languageCode);
  }

  Future<bool> migrated() async => getBool(SharedPreferencesKeys.migrated);

  Future<void> setMigrated() async =>
      setBool(SharedPreferencesKeys.migrated, true);

  Future<bool> projectsReversed() async =>
      getBool(SharedPreferencesKeys.projectsReversed);

  Future<void> setProjectsReversed({required final bool reversed}) async =>
      setBool(SharedPreferencesKeys.projectsReversed, reversed);
}
