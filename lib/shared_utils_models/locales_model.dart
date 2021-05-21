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

final Map<String, NamedLocale> namedLocalesMap = {
  Locales.en.languageCode: const NamedLocale(
    name: 'English',
    locale: Locales.en,
  ),
  Locales.ru.languageCode: const NamedLocale(
    name: 'Русский',
    locale: Locales.ru,
  ),
};
final namedLocales = namedLocalesMap.values.toList();

class LocaleModelConsts {
  static const String storagename = 'locale';
}

class LocaleModel extends ChangeNotifier with StorageMixin {
  Locale _locale = Locales.en;
  Locale get locale => _locale;
  set locale(Locale localef) {
    _locale = localef;
    notifyListeners();
  }

  LocaleModel._();
  factory LocaleModel.fromLocale({
    required Locale locale,
  }) {
    final localeModel = LocaleModel._();
    localeModel._locale = locale;
    return localeModel;
  }

  static Future<Locale> loadSavedLocale() async {
    final storage = await StorageUtil.getInstance();
    final localeStr = storage.getString(LocaleModelConsts.storagename);
    if (localeStr.isEmpty) {
      // FIXME: strange things happend with locales on all OS!
      // seems like it has new formats nn__UTF08__NN
      if (isDesktop) return Locales.en;

      final systemLocale = await findSystemLocale();
      Intl.defaultLocale = systemLocale;
      return Locale(Intl.defaultLocale ?? Languages.en);
    }

    final localeCanon = Intl.canonicalizedLocale(localeStr);
    final localef = Locale(localeCanon, localeCanon.toUpperCase());
    return localef;
  }

  Future<void> switchLang(Locale? localef) async {
    if (localef == null) return;
    await AppLocalizations.delegate.load(localef);
    (await storage)
        .putString(LocaleModelConsts.storagename, localef.languageCode);
    locale = localef;
  }

  NamedLocale get currentNamedLocale => namedLocales.firstWhere((namedLocale) {
        final isEqual = _locale.languageCode == namedLocale.locale.languageCode;
        return isEqual;
      });
}
