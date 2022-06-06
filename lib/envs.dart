class Envs {
  Envs._();

  /// ********************************************
  /// *      GOOGLE START
  /// ********************************************

  static const revenueCatApiKeyGoogle =
      String.fromEnvironment('revenue-cat-api-key-google');

  static bool get revenueCatApiKeyGoogleIsEmpty =>
      revenueCatApiKeyGoogle.isEmpty;

  static bool get revenueCatApiKeyGoogleIsNotEmpty =>
      revenueCatApiKeyGoogle.isNotEmpty;

  /// ********************************************
  /// *      APPLE START
  /// ********************************************

  static const revenueCatApiKeyApple =
      String.fromEnvironment('revenue-cat-api-key-apple');

  static bool get revenueCatApiKeyAppleIsEmpty => revenueCatApiKeyApple.isEmpty;

  static bool get revenueCatApiKeyAppleIsNotEmpty =>
      revenueCatApiKeyApple.isNotEmpty;

  /// ********************************************
  /// *      SUPABASE START
  /// ********************************************

  static const supabaseUrl = String.fromEnvironment('supabase-url');
  static const supabaseAnon = String.fromEnvironment('supabase-anon');
}
