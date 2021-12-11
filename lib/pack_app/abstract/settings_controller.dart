part of pack_app;

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
// ignore: prefer_mixin
class SettingsController with ChangeNotifier {
  SettingsController({required final this.settingsService});

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(final ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Dot not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new theme mode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notify();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await settingsService.setThemeMode(newThemeMode);
  }

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> updateLocale(final Locale? locale) async {
    if (locale == null) return;

    if (locale == _locale) return;
    _locale = locale;
    await S.load(locale);
    notify();

    await settingsService.setLocale(locale);
  }

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> load() async {
    _themeMode = await settingsService.themeMode();
    _locale = await settingsService.locale();
    migrated = await settingsService.migrated();
    _projectsListReversed = await settingsService.projectsReversed();

    // Important! Inform listeners a change has occurred.
    notify();
  }

  AppStateLoadingStatuses? _loadingStatus;

  AppStateLoadingStatuses? get loadingStatus => _loadingStatus;

  set loadingStatus(final AppStateLoadingStatuses? loadingStatus) {
    _loadingStatus = loadingStatus;
    notify();
  }

  bool migrated = false;
  Future<void> setMigrated() async {
    migrated = true;
    return settingsService.setMigrated();
  }

  bool _projectsListReversed = isDesktop;

  bool get projectsListReversed => _projectsListReversed;

  set projectsListReversed(final bool projectsReversed) {
    _projectsListReversed = projectsReversed;
    notify();
    settingsService.setProjectsReversed(reversed: projectsReversed);
  }

  void notify() => notifyListeners();
}

/// Provides the current [SettingsController] to descendent widgets in the tree.
class SettingsStateScope extends InheritedNotifier<SettingsController> {
  const SettingsStateScope({
    required final SettingsController notifier,
    required final Widget child,
    final Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static SettingsController of(final BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<SettingsStateScope>()
        ?.notifier;
    if (state == null) throw ArgumentError.notNull('SettingsStateScope');
    return state;
  }
}