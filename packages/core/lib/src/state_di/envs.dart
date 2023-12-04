// ignore_for_file: do_not_use_environment

class Envs {
  static const isarDbName = 'isar_4';
  static const sembastWebDbName = 'sembast_web';
  static const sembastWebDbVersion = 1;
  static bool get isFeedbackAvailable => wiredashProjectId.isNotEmpty;
  static const wiredashProjectId =
      String.fromEnvironment('WIREDASH_PROJECT_ID');
  static const wiredashProjectSecret =
      String.fromEnvironment('WIREDASH_PROJECT_SECRET');
}
