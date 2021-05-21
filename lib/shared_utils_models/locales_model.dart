import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:lastanswer/abstract/language.dart';
import 'package:lastanswer/abstract/named_locale.dart';
import 'package:lastanswer/shared_utils_models/storage_mixin.dart';
import 'package:lastanswer/shared_utils_models/storage_util.dart';
import 'package:lastanswer/utils/is_desktop.dart';

class LocaleModelConsts {
  static final String storagename = 'locale';
  static final Map<String, NamedLocale> namedLocalesMap = {
    Locales.en.languageCode: NamedLocale(
      name: 'English',
      locale: Locales.en,
    ),
    Locales.ru.languageCode: NamedLocale(
      name: 'Русский',
      locale: Locales.ru,
    ),
  };
  static final List<NamedLocale> namedLocales = namedLocalesMap.values.toList();
}

class LocaleModel extends ChangeNotifier with StorageMixin {
  Locale _locale = Locales.en;
  Locale get locale => _locale;
  set locale(Locale localef) {
    _locale = localef;
    notifyListeners();
  }

  LocaleModel();
  factory LocaleModel.fromLocale({
    required Locale locale,
  }) {
    var localeModel = LocaleModel();
    localeModel._locale = locale;
    return localeModel;
  }

  static Future<Locale> loadSavedLocale() async {
    StorageUtil storage = await StorageUtil.getInstance();
    String localeStr = storage.getString(LocaleModelConsts.storagename);
    if (localeStr.isEmpty) {
      // FIXME: strange things happend with locales on all OS!
      // seems like it has new formats nn__UTF08__NN
      if (isDesktop()) return Locales.en;

      var systemLocale = await findSystemLocale();
      Intl.defaultLocale = systemLocale;
      return Locale(Intl.defaultLocale ?? Languages.en);
    }

    String localeCanon = Intl.canonicalizedLocale(localeStr);
    Locale localef = Locale(localeCanon, localeCanon.toUpperCase());
    return localef;
  }

  Future<void> switchLang(Locale? localef) async {
    if (localef == null) return;
    await AppLocalizations.delegate.load(localef);
    (await storage)
        .putString(LocaleModelConsts.storagename, localef.languageCode);
    locale = localef;
  }

  NamedLocale get currentNamedLocale =>
      LocaleModelConsts.namedLocales.firstWhere((namedLocale) {
        var isEqual = _locale.languageCode == namedLocale.locale.languageCode;
        return isEqual;
      });
}
