import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core.dart';

/// This service purpose to manage shared preferences only
class SharedPreferencesDbDataSourceImpl implements LocalDbDataSource, Loadable {
  // ignore: avoid_unused_constructor_parameters
  SharedPreferencesDbDataSourceImpl(final BuildContext context);
  // cached SharedPreferences instance
  late final SharedPreferences _sharedPreferences;
  SharedPreferences get _prefs => _sharedPreferences;
  @override
  Future<void> onLoad() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void setMap({
    required final String key,
    required final Map<String, dynamic> value,
  }) =>
      setString(key: key, value: jsonEncode(value));

  @override
  Map<String, dynamic> getMap(
    final String key,
  ) {
    final str = getString(key: key);
    if (str.isEmpty) return {};

    return Map.castFrom<dynamic, dynamic, String, dynamic>(
      jsonDecode(str),
    );
  }

  @override
  void setString({
    required final String key,
    required final String value,
  }) {
    unawaited(_prefs.setString(key, value));
  }

  @override
  String getString({
    required final String key,
    final String defaultValue = '',
  }) {
    final value = _prefs.getString(key);

    return value ?? defaultValue;
  }

  @override
  void setBool({
    required final String key,
    required final bool value,
  }) {
    unawaited(_prefs.setBool(key, value));
  }

  @override
  bool getBool({
    required final String key,
    final bool defaultValue = false,
  }) =>
      _prefs.getBool(key) ?? defaultValue;

  @override
  void setInt({
    required final String key,
    required final int? value,
  }) =>
      unawaited(_prefs.setInt(key, value ?? 0));

  @override
  int getInt({
    required final String key,
    final int defaultValue = 0,
  }) =>
      _prefs.getInt(key) ?? defaultValue;

  @override
  Iterable<Map<String, dynamic>> getMapIterable({
    required final String key,
    final List<Map<String, dynamic>> defaultValue = const [],
  }) {
    final strings = getStringsIterable(key: key);

    return strings.map(
      (final e) =>
          Map.castFrom<dynamic, dynamic, String, dynamic>(jsonDecode(e)),
    );
  }

  @override
  void setMapList({
    required final String key,
    required final List<Map<String, dynamic>> value,
  }) {
    final stringList = value.map(jsonEncode).toList();
    setStringList(key: key, value: stringList);
  }

  @override
  Iterable<String> getStringsIterable({
    required final String key,
    final List<String> defaultValue = const [],
  }) =>
      _prefs.getStringList(key) ?? [];

  @override
  void setStringList({
    required final String key,
    required final List<String> value,
  }) {
    unawaited(_prefs.setStringList(key, value));
  }

  @override
  void setItemsList<T>({
    required final String key,
    required final List<T> value,
    required final Map<String, dynamic> Function(T e) convertToJson,
  }) {
    setMapList(key: key, value: value.map(convertToJson).toList());
  }

  @override
  Iterable<T> getItemsIterable<T>({
    required final String key,
    required final T Function(Map<String, dynamic> json) convertFromJson,
    final List<T> defaultValue = const [],
  }) {
    final jsons = getMapIterable(key: key);
    if (jsons.isEmpty) return defaultValue;

    return jsons.map(convertFromJson);
  }

  @override
  T? getItem<T>({
    required final String key,
    required final T Function(Map<String, dynamic> json) convertFromJson,
  }) {
    final json = getMap(key);
    if (json.isEmpty) return null;

    return convertFromJson(json);
  }

  @override
  void setItem<T>({
    required final String key,
    required final T value,
    required final Map<String, dynamic> Function(T e) convertToJson,
  }) {
    final json = convertToJson(value);
    setMap(key: key, value: json);
  }
}
