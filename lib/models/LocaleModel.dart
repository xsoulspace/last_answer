import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:flutter/cupertino.dart';

class LocaleModel extends ChangeNotifier {
  Locale _locale = Locale('en','EN');
  switchLang(Locale locale) {
    MainLocalizations.load(locale);
    _locale = locale;
    notifyListeners();
  }

  String get current => _locale.languageCode;
}
