import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:howtosolvethequest/utils/storage_util.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

class Consts {
  static const locale = 'locale';
}

class LocaleModel extends ChangeNotifier {
  Locale _locale = Locale('en', 'EN');
  StorageUtil _storage;
  _iniStorage() async {
    if (_storage == null) {
      _storage = await StorageUtil.getInstance();
    }
  }

  static Future<Locale> loadSavedLocale() async {
    StorageUtil store = await StorageUtil.getInstance();
    String localeStr = store.getString(Consts.locale);

    if (localeStr == null || localeStr == '') {
      Intl.defaultLocale = await findSystemLocale();
      return Locale(Intl.defaultLocale);
    }
    print('ini locale $localeStr');

    String localeCanon = Intl.canonicalizedLocale(localeStr);
    print('ini localeCanon $localeCanon');

    Locale locale = Locale(localeCanon, localeCanon.toUpperCase());
    print(locale.toString());
    return locale;
  }

  notifyAboutLang() {
    notifyListeners();
  }

  Future<void> switchLang(Locale locale) async {
    await _iniStorage();
    await _storage.putString(Consts.locale, locale.languageCode);
    MainLocalizations.load(locale);
    _locale = locale;
    notifyListeners();
  }

  String get current => _locale.languageCode;
}
