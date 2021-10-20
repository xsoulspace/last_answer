part of utils;

/// This service purpose to manage shared preferences only
mixin SharedPreferencesUtil {
  // cached SharedPreferences instance
  SharedPreferences? _sharedPreferences;
  Future<SharedPreferences> get sharedPreferences async =>
      _sharedPreferences ??= await SharedPreferences.getInstance();

  Future<void> setMap(
    final String key,
    final Map<String, dynamic> value,
  ) async =>
      setString(key, jsonEncode(value));

  Future<void> setString(final String key, final String value) async {
    final prefs = await sharedPreferences;
    await prefs.setString(key, value);
  }

  Future<Map<String, dynamic>> getMap(
    final String key,
  ) async {
    final str = await getString(key);
    if (str.isEmpty) return {};
    return Map.castFrom<dynamic, dynamic, String, dynamic>(
      jsonDecode(str),
    );
  }

  Future<String> getString(
    final String key, {
    final String defaultValue = '',
  }) async {
    final prefs = await sharedPreferences;
    final value = prefs.getString(key);
    return value ?? defaultValue;
  }
}
