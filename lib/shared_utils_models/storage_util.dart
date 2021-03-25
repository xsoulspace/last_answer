import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static StorageUtil? _storageUtil;
  static SharedPreferences? _preferences;

  static Future<StorageUtil> getInstance() async {
    var storageUtil = _storageUtil;
    if (storageUtil == null) {
      // keep local instance till it is fully initialized.
      StorageUtil secureStorage = StorageUtil._();
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
    var preferences = _preferences;
    if (preferences == null) return defValue;
    return preferences.getString(key) ?? defValue;
  }

  // put string
  Future<bool> putString(String key, String value) async {
    var preferences = _preferences;

    if (preferences == null) return false;
    return await preferences.setString(key, value);
  }
}
