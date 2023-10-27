// ignore_for_file: do_not_use_environment

class Envs {
  Envs._();
  static const revenueCatApiKeyGoogle =
      String.fromEnvironment('revenue-cat-api-key-google');
  static bool get revenueCatApiKeyGoogleIsEmpty =>
      revenueCatApiKeyGoogle.isEmpty;
  static bool get revenueCatApiKeyGoogleIsNotEmpty =>
      revenueCatApiKeyGoogle.isNotEmpty;

  static const revenueCatApiKeyApple =
      String.fromEnvironment('revenue-cat-api-key-apple');
  static bool get revenueCatApiKeyAppleIsEmpty => revenueCatApiKeyApple.isEmpty;
  static bool get revenueCatApiKeyAppleIsNotEmpty =>
      revenueCatApiKeyApple.isNotEmpty;
}
