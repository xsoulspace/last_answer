import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_lib;

class GlobalStateNotifiers {
  GlobalStateNotifiers._();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  static final settings =
      GeneralSettingsController(settingsService: SettingsService());

  static final supabase_lib.SupabaseClient supabase =
      supabase_lib.Supabase.instance.client;
}
