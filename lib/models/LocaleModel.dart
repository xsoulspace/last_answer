import 'package:howtosolvequest/localizations/MainLocalizations.dart';
import 'package:flutter/cupertino.dart';

class LocaleModel extends ChangeNotifier {
  Locale _locale = Locale('ru','RU');
  switchLang(Locale locale) {
    MainLocalizations.load(locale);
    _locale = locale;
    notifyListeners();
  }

  String get current => _locale.languageCode;
}
