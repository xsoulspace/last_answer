import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';

import '../../../core.dart';

class LocaleLogic {
  LocaleLogic();

  Future<Locale> get _defaultLocale async {
    final systemLocaleStr = await findSystemLocale();

    final systemLocale = Locale.fromSubtags(
      languageCode: systemLocaleStr.substring(0, 2),
    );
    final isSupported = S.delegate.isSupported(systemLocale);
    if (isSupported) return systemLocale;
    return Locales.en;
  }

  /// Ui locale will not be saved, and will always be in runtime
  /// updatedLocale is the one that will be saved.
  Future<({Locale? updatedLocale, Locale uiLocale})?> updateLocale({
    required final Locale? newLocale,
    required final Locale? oldLocale,
    required final Locale uiLocale,
  }) async {
    final didChanged = oldLocale?.languageCode != newLocale?.languageCode;
    if (!didChanged) return null;

    Locale? updatedLocale = oldLocale;
    Locale updatedUiLocale = uiLocale;
    final defaultLocale = await _defaultLocale;
    if (newLocale == null) {
      unawaited(S.delegate.load(defaultLocale));
      updatedLocale = null;
      updatedUiLocale = defaultLocale;
    } else {
      final language = Languages.byLanguageCode(newLocale.languageCode);
      final localeCandidate = Locales.byLanguage(language);
      if (S.delegate.isSupported(localeCandidate)) {
        unawaited(S.delegate.load(localeCandidate));
        updatedLocale = localeCandidate;
        updatedUiLocale = localeCandidate;
      }
    }

    return (
      updatedLocale: updatedLocale,
      uiLocale: updatedUiLocale,
    );
  }
}
