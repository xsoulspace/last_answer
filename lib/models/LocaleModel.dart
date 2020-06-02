import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:howtosolvethequest/utils/storage_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Consts {
  static const locale = 'locale';
}

class LocaleModel extends ChangeNotifier {
  Locale _locale = Locale('en', 'EN');

  loadSavedLocale() async {
    String countryCode = StorageUtil.getString(Consts.locale);
    if(countryCode == null) return;
    String localeCanon = Intl.canonicalizedLocale(countryCode);
    Locale locale = Locale(localeCanon);
    locale = locale ?? Intl.systemLocale;
    MainLocalizations.load(locale);
    _locale = locale;
    notifyListeners();
  }

  switchLang(Locale locale) async {
    StorageUtil.putString(Consts.locale, _locale.countryCode);

    MainLocalizations.load(locale);
    _locale = locale;
    notifyListeners();
  }

  String get current => _locale.languageCode;
}
