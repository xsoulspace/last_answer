import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataService {
  Future<void> setMap(
    final String key,
    final Map<String, dynamic> value,
  );
  Future<Map<String, dynamic>> getMap(
    final String key,
  );
  Future<void> setString(final String key, final String value);
  Future<String> getString(
    final String key, {
    final String defaultValue = '',
  });
  // ignore: avoid_positional_boolean_parameters
  Future<void> setBool(final String key, final bool value);
  Future<bool> getBool(
    final String key, {
    final bool defaultValue = false,
  });
  Future<void> setInt(final String key, final int? value);
  Future<int> getInt(
    final String key, {
    final int defaultValue = 0,
  });
}

/// This service purpose to manage shared preferences only
class SharedPreferencesDataService implements LocalDataService {
  // cached SharedPreferences instance
  SharedPreferences? _sharedPreferences;
  Future<SharedPreferences> get sharedPreferences async =>
      _sharedPreferences ??= await SharedPreferences.getInstance();

  @override
  Future<void> setMap(
    final String key,
    final Map<String, dynamic> value,
  ) async =>
      setString(key, jsonEncode(value));

  @override
  Future<Map<String, dynamic>> getMap(
    final String key,
  ) async {
    final str = await getString(key);
    if (str.isEmpty) return {};

    return Map.castFrom<dynamic, dynamic, String, dynamic>(
      jsonDecode(str),
    );
  }

  @override
  Future<void> setString(final String key, final String value) async {
    final prefs = await sharedPreferences;
    await prefs.setString(key, value);
  }

  @override
  Future<String> getString(
    final String key, {
    final String defaultValue = '',
  }) async {
    final prefs = await sharedPreferences;
    final value = prefs.getString(key);

    return value ?? defaultValue;
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setBool(final String key, final bool value) async {
    final prefs = await sharedPreferences;
    await prefs.setBool(key, value);
  }

  @override
  Future<bool> getBool(
    final String key, {
    final bool defaultValue = false,
  }) async {
    final prefs = await sharedPreferences;

    return prefs.getBool(key) ?? defaultValue;
  }

  @override
  Future<void> setInt(final String key, final int? value) async {
    final prefs = await sharedPreferences;
    await prefs.setInt(key, value ?? 0);
  }

  @override
  Future<int> getInt(
    final String key, {
    final int defaultValue = 0,
  }) async {
    final prefs = await sharedPreferences;

    return prefs.getInt(key) ?? defaultValue;
  }
}
