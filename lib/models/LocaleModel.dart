import 'package:flutter/foundation.dart';
import 'package:lastanswer/entities/NamedLocale.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:lastanswer/utils/storage_util.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

class LocaleModelConsts {
  static const locale = 'locale';
  static const localeEN = Locale('en', 'EN');
  static const localeRU = Locale('ru', 'RU');
  static final List<NamedLocale> namedLocales = [
    NamedLocale(
      name: 'English',
      locale: LocaleModelConsts.localeEN,
    ),
    NamedLocale(
      name: 'Русский',
      locale: LocaleModelConsts.localeRU,
    ),
  ];
}

class LocaleModel extends ChangeNotifier {
  Locale _locale = LocaleModelConsts.localeEN;
  StorageUtil _storage;
  _iniStorage() async {
    if (_storage == null) {
      _storage = await StorageUtil.getInstance();
    }
  }

  static Future<Locale> loadSavedLocale() async {
    StorageUtil store = await StorageUtil.getInstance();
    String localeStr = store.getString(LocaleModelConsts.locale);

    if (localeStr == null || localeStr == '') {
      if (kIsWeb) {
        return LocaleModelConsts.localeEN;
      }
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
    await _storage.putString(LocaleModelConsts.locale, locale.languageCode);
    MainLocalizations.load(locale);
    _locale = locale;
    notifyListeners();
  }

  String get current => _locale.languageCode;
  NamedLocale get currentNamedLocale => LocaleModelConsts.namedLocales
      .firstWhere((namedLocale) => _locale == namedLocale.locale);
}
