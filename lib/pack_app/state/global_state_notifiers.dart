part of pack_app;

class GlobalStateNotifiers {
  GlobalStateNotifiers._();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  static final settings =
      SettingsController(settingsService: SettingsService());
}