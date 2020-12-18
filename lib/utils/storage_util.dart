import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static StorageUtil? _storageUtil;
  static SharedPreferences? _preferences;

  Future<SharedPreferences> get preferences async {
    return _preferences ??
        await (() async {
          return await SharedPreferences.getInstance();
        })();
  }

  static Future<StorageUtil> getInstance() async {
    var storage = _storageUtil ??
        await (() async {
          // keep local instance till it is fully initialized.
          StorageUtil secureStorage = StorageUtil._();
          _storageUtil = secureStorage;
          return secureStorage;
        })();
    return storage;
  }

  StorageUtil._();

  // get string
  Future<String> getString(String key, {String defValue = ''}) async {
    return (await preferences).getString(key) ?? defValue;
  }

  // put string
  Future putString(String key, String value) async {
    return (await preferences).setString(key, value);
  }
}
