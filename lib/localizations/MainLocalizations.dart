import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:howtosolvequest/l10n/messages_all.dart';
// flutter pub run intl_translation:generate_from_arb \ --output-dir=lib/l10n --no-use-deferred-loading \ lib/l10n/intl_messages.arb lib/l10n/intl_en.arb lib/l10n/intl_ru.arb lib/localizations/MainLocalizations.dart
// flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/locale/app_localization.dart
// flutter pub run intl_translation:generate_from_arb \ --output-dir=lib/l10n --no-use-deferred-loading \ lib/main.dart lib/l10n/intl_en.arb lib/l10n/intl_ru.arb lib/localizations/MainLocalizations.dart
class Language {
  static String ru = 'ru';
  static String en = 'en';
  static final List items = [ru, en];
  static String get current => Intl.getCurrentLocale().replaceAll(RegExp(r'\_.*$'), '');
  static List get all => items;
}

class MainLocalizations {

  static Future<MainLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return MainLocalizations();
    });
  }

  static MainLocalizations of(BuildContext context) {
    return Localizations.of<MainLocalizations>(context, MainLocalizations);
  }

  String get answers {
    return Intl.message('Answers',
        name: 'answers', desc: 'menu title points to answers');
  }
  String get save {
    return Intl.message('Save',
        name: 'save', desc: 'menu title save');
  }
  String get lastAnswer {
    return Intl.message('Last Answer',
        name: 'lastAnswer', desc: 'menu title Last answer');
  }
}

class MainLocalizationsDelegate
    extends LocalizationsDelegate<MainLocalizations> {
  final Locale overridenLocale;
  Locale get locale => overridenLocale;

  const MainLocalizationsDelegate(this.overridenLocale);

  @override
  bool isSupported(Locale locale) => Language.all.contains(locale.languageCode);

  @override
  Future<MainLocalizations> load(Locale locale) =>
      MainLocalizations.load(locale);

  @override
  bool shouldReload(MainLocalizationsDelegate old) => false;
}
