class Envs {
  Envs._();
  static const revenueCatApiKey = String.fromEnvironment('revenue-cat-api-key');
  static bool get revenueCatApiKeyIsEmpty => revenueCatApiKey.isEmpty;
  static bool get revenueCatApiKeyIsNotEmpty => revenueCatApiKey.isNotEmpty;
}
