import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lastanswer/l10n/messages_all.dart';

// https://medium.com/@puneetsethi25/flutter-internationalization-switching-locales-manually-f182ec9b8ff0
// flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localizations/MainLocalizations.dart
// flutter pub run intl_translation:generate_from_arb \ --output-dir=lib/l10n --no-use-deferred-loading \ lib/main.dart lib/l10n/intl_en.arb lib/l10n/intl_ru.arb lib/localizations/MainLocalizations.dart
class Language {
  static String ru = 'ru';
  static String en = 'en';
  static final List items = [ru, en];
  static List get all => items;
}

class MainLocalizations {
  static Future<MainLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    // print('main localizaions $name, $locale');
    final String localeName = Intl.canonicalizedLocale(name);
    // print('main localizaions $localeName');

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
    return Intl.message('Save', name: 'save', desc: 'menu title save');
  }

  String get lastAnswer {
    return Intl.message('Last Answer',
        name: 'lastAnswer', desc: 'menu title Last answer');
  }

  String get answer {
    return Intl.message('Answer', name: 'answer', desc: 'answer input');
  }

  String get newQuest {
    return Intl.message('Start new Quest',
        name: 'newQuest', desc: 'popup start');
  }

  String get newQuestDesc {
    return Intl.message(
        'This action will clear all previous answers. Be sure that you saved them, if its needed.',
        name: 'newQuestDesc',
        desc: 'popup start desc');
  }

  String get newQuestStart {
    return Intl.message('start',
        name: 'newQuestStart', desc: 'popup start start');
  }

  String get newQuestCancel {
    return Intl.message('cancel',
        name: 'newQuestCancel', desc: 'popup start cancel');
  }

  String get cancel {
    return Intl.message('cancel', name: 'cancel', desc: 'cancel');
  }

  String get delete {
    return Intl.message('delete', name: 'delete', desc: 'delete');
  }

  String get successfullyDeleted {
    return Intl.message('Successfully deleted!',
        name: 'successfullyDeleted', desc: 'Successfully deleted');
  }

  String get successfullySaved {
    return Intl.message('Successfully saved!',
        name: 'successfullySaved', desc: 'Successfully saved');
  }

  String get theAnswerCannotBeEmpty {
    return Intl.message('The answer cannot be empty',
        name: 'theAnswerCannotBeEmpty',
        desc: 'The answer cannot be empty during editing on Answers page');
  }

  String get areYouSureYouWantToDeleteAnswer {
    return Intl.message('Are you want to delete answer?',
        name: 'areYouSureYouWantToDeleteAnswer',
        desc: 'Warning Title for answer delete');
  }

  String get ifYouDeleteAnswerThereIsNoWayBack {
    return Intl.message('If you delete the answer it will be lost',
        name: 'ifYouDeleteAnswerThereIsNoWayBack',
        desc: 'Warning for answer delete');
  }

  // PHILOSPHY ABSTRACT

  String get philosophyAndInspirationTitle =>
      Intl.message('Philosophy & Inspiration',
          name: 'philosophyAndInspirationTitle',
          desc: 'Philosopy & Inspiration');
  String get philosophyAbstractTitle => Intl.message('Philosophy Abstract',
      name: 'philosophyAbstractTitle', desc: 'Philosophy Abstract');
  String get philosophyAbstractWhatElse => Intl.message('What else?',
      name: 'philosophyAbstractWhatElse', desc: 'Philosophy Abstract');
  String get philosophyAbstractFiveWhyesWhat =>
      Intl.message('You can use: "Five whys"',
          name: 'philosophyAbstractFiveWhyesWhat',
          desc: 'Method that you can use');
  String get philosophyAbstractFiveWhyesWhy => Intl.message(
      'Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as "cause and effect" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys',
      name: 'philosophyAbstractFiveWhyesWhy',
      desc: 'Description of Five Whyes');
  String get philosophyAbstractPDSAWhy => Intl.message(
      'You can use: "PDCA (Plan-Do-Study-Act): Shewhart-Deming cycle"',
      name: 'philosophyAbstractPDSAWhy',
      desc: 'Method that you can use');
  String get philosophyAbstractPDSAWhat => Intl.message(
      'Because it most universal technique. It does not solid questions, as in "Five Whys", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA',
      name: 'philosophyAbstractPDSAWhat',
      desc: 'Description of PDSA');
  String get philosophyAbstractSixSigmaWhy =>
      Intl.message('You can use: "Six Sigma"',
          name: 'philosophyAbstractSixSigmaWhy',
          desc: 'Method that you can use');
  String get philosophyAbstractSixSigmaWhat => Intl.message(
      'Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma',
      name: 'philosophyAbstractSixSigmaWhat',
      desc: 'Description of Six Sigma');

// ABOUT ABSTRACT

  String get aboutAbstractTitle => Intl.message('About Abstract',
      name: 'aboutAbstractTitle', desc: 'About Abstract title');
  String get aboutAbstractWhatFor => Intl.message('What for?',
      name: 'aboutAbstractWhatFor', desc: 'What For About Abstract');
  String get aboutAbstractWhatForDescription => Intl.message(
      'I\'m designing this app to solve problems complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.',
      name: 'aboutAbstractWhatForDescription',
      desc: 'Description of About Abstract');
  String get aboutAbstractHowDescription => Intl.message(
      'You can use Philosophy Abstract to get ideas how this app can be used and in which techniques.',
      name: 'aboutAbstractHowDescription',
      desc: 'Description of About Abstract How Description');
  String get aboutAbstractIdeasImprovementsBugs =>
      Intl.message('Ideas Improvements Bugs?',
          name: 'aboutAbstractIdeasImprovementsBugs',
          desc: 'Ideas Improvements Bugs');
  String get aboutAbstractIdeasImprovementsBugsDescription => Intl.message(
      'Please leave a message in Google Play, App Store or to xsoulspace@gmail.com. Thank you!',
      name: 'aboutAbstractIdeasImprovementsBugsDescription',
      desc: 'Ideas Improvements Bugs description');
}

class MainLocalizationsDelegate
    extends LocalizationsDelegate<MainLocalizations> {
  final Locale overridenLocale;

  const MainLocalizationsDelegate(this.overridenLocale);

  @override
  bool isSupported(Locale locale) =>
      locale != null ? Language.all.contains(locale.languageCode) : false;

  @override
  Future<MainLocalizations> load(Locale locale) =>
      MainLocalizations.load(locale);

  @override
  bool shouldReload(MainLocalizationsDelegate old) => false;
}
