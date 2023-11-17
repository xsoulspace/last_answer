import '../../foundation/foundation.dart';

abstract interface class LocalDbDataSource implements Loadable {
  void setMap({
    required final String key,
    required final Map<String, dynamic> value,
  });
  Map<String, dynamic> getMap(
    final String key,
  );
  void setString({
    required final String key,
    required final String value,
  });
  String getString({
    required final String key,
    final String defaultValue = '',
  });
  void setBool({required final String key, required final bool value});
  bool getBool({
    required final String key,
    final bool defaultValue = false,
  });
  void setInt({required final String key, required final int? value});
  int getInt({
    required final String key,
    final int defaultValue = 0,
  });

  void setItem<T>({
    required final String key,
    required final T value,
    required final Map<String, dynamic> Function(T) convertToJson,
  });

  T? getItem<T>({
    required final String key,
    required final T Function(Map<String, dynamic>) convertFromJson,
  });

  void setItemsList<T>({
    required final String key,
    required final List<T> value,
    required final Map<String, dynamic> Function(T) convertToJson,
  });
  Iterable<T> getItemsIterable<T>({
    required final String key,
    required final T Function(Map<String, dynamic>) convertFromJson,
    final List<T> defaultValue = const [],
  });

  void setMapList({
    required final String key,
    required final List<Map<String, dynamic>> value,
  });
  Iterable<Map<String, dynamic>> getMapIterable({
    required final String key,
    final List<Map<String, dynamic>> defaultValue = const [],
  });
  void setStringList({
    required final String key,
    required final List<String> value,
  });
  Iterable<String> getStringsIterable({
    required final String key,
    final List<String> defaultValue = const [],
  });
}
