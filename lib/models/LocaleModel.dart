import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:lastanswer/entities/NamedLocale.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/models/StorageMixin.dart';
import 'package:lastanswer/utils/storage_util.dart';

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

class LocaleModel extends ChangeNotifier with StorageMixin {
  bool isInitialized = false;
  Locale _locale = LocaleModelConsts.localeEN;

  static Future<Locale> loadSavedLocale() async {
    StorageUtil store = await StorageUtil.getInstance();
    String localeStr = await store.getString(LocaleModelConsts.locale);

    if (localeStr == '') {
      if (kIsWeb || Platform.isWindows) {
        return LocaleModelConsts.localeEN;
      }
      Intl.defaultLocale = await findSystemLocale();
      return Locale(Intl.defaultLocale);
    }
    // print('ini locale $localeStr');

    String localeCanon = Intl.canonicalizedLocale(localeStr);
    // print('ini localeCanon $localeCanon');

    Locale locale = Locale(localeCanon, localeCanon.toUpperCase());
    // print(locale.toString());
    return locale;
  }

  notifyAboutLang() {
    notifyListeners();
  }

  Future<void> switchLang(Locale? locale) async {
    var fixedLocale = LocaleModelConsts.localeEN;
    (await storage)
        .putString(LocaleModelConsts.locale, fixedLocale.languageCode);
    MainLocalizations.load(fixedLocale);
    _locale = fixedLocale;
    notifyListeners();
  }

  String get current => _locale.languageCode;
  NamedLocale get currentNamedLocale => LocaleModelConsts.namedLocales
      .firstWhere((namedLocale) => _locale == namedLocale.locale);
}
