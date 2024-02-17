// ignore_for_file: do_not_use_environment

class Envs {
  Envs._();
  static const isarDbName = 'isar_4';
  static const serverHost = String.fromEnvironment(
    'SERVER_HOST',
    defaultValue: 'http://localhost:8080/',
  );
  static final serverRedirectUri = Uri.parse(
    '${const String.fromEnvironment(
      "SERVER_REDIRECT_HOST",
      defaultValue: "http://localhost:8082/",
    )}googlesignin',
  );
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static bool get isFeedbackAvailable => wiredashProjectId.isNotEmpty;
  static const wiredashProjectId =
      String.fromEnvironment('WIREDASH_PROJECT_ID');
  static const wiredashProjectSecret =
      String.fromEnvironment('WIREDASH_PROJECT_SECRET');
  static final store = StoreType.fromEnv();
}

enum StoreType {
  googlePlay,
  rustore,
  huawaiStore,
  appleStore,
  xsoulspaceWebsite,
  snapstore,
  windowsStore;

  static StoreType fromEnv() => values.byName(
        const String.fromEnvironment('STORE', defaultValue: 'snapstore'),
      );
}
