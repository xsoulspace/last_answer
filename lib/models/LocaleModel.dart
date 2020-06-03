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
  LocaleModel() {
    StorageUtil.getInstance().then((inst) => _storage = inst);
  }
  static Future<Locale> loadSavedLocale() async {
    StorageUtil store = await StorageUtil.getInstance();
    Intl.defaultLocale = await findSystemLocale();
    String countryCode = store.getString(Consts.locale);
    if (countryCode == null || countryCode == '')
      return Locale(Intl.canonicalizedLocale(Intl.defaultLocale));
    String localeCanon = Intl.canonicalizedLocale(countryCode);
    Locale locale = Locale(localeCanon);
    return locale;
  }

  switchLang(Locale locale) async {
    await _storage.putString(Consts.locale, _locale.countryCode);

    MainLocalizations.load(locale);
    _locale = locale;
    notifyListeners();
  }

  String get current => _locale.languageCode;
}
