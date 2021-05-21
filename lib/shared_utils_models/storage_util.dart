import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static StorageUtil? _storageUtil;
  static SharedPreferences? _preferences;

  static Future<StorageUtil> getInstance() async =>
      _storageUtil ??= StorageUtil._().._init();

  StorageUtil._();
  Future<SharedPreferences> _init() async =>
      _preferences = await SharedPreferences.getInstance();

  // get string
  String getString(String key, {String defValue = ''}) {
    final preferences = _preferences;
    if (preferences == null) return defValue;
    return preferences.getString(key) ?? defValue;
  }

  // put string
  Future<bool> putString(String key, String value) async {
    final preferences = _preferences;
    if (preferences == null) return false;
    return preferences.setString(key, value);
  }
}
