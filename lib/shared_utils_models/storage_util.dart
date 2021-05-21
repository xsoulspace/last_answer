import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static StorageUtil? _storageUtil;
  static SharedPreferences? _preferences;

  static Future<StorageUtil> getInstance() async {
    StorageUtil? storageUtil = _storageUtil;
    if (storageUtil == null) {
      // keep local instance till it is fully initialized.
      final secureStorage = StorageUtil._();
      await secureStorage._init();
      _storageUtil = secureStorage;
      storageUtil = secureStorage;
    }
    return storageUtil;
  }

  StorageUtil._();
  Future _init() async => _preferences = await SharedPreferences.getInstance();

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
