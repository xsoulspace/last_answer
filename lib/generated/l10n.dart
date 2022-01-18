// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'menu title language',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: 'Search',
      args: [],
    );
  }

  /// `Write an answer`
  String get writeAnAnswer {
    return Intl.message(
      'Write an answer',
      name: 'writeAnAnswer',
      desc: 'writeAnAnswer',
      args: [],
    );
  }

  /// `Write a note`
  String get writeANote {
    return Intl.message(
      'Write a note',
      name: 'writeANote',
      desc: 'writeANote',
      args: [],
    );
  }

  /// `Characters limit`
  String get charactersLimit {
    return Intl.message(
      'Characters limit',
      name: 'charactersLimit',
      desc: 'charactersLimit',
      args: [],
    );
  }

  /// `When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.`
  String get charactersLimitForNewNotesDesription {
    return Intl.message(
      'When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.',
      name: 'charactersLimitForNewNotesDesription',
      desc:
          'When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.',
      args: [],
    );
  }

  /// `Other`
  String get charactersUnlimited {
    return Intl.message(
      'Other',
      name: 'charactersUnlimited',
      desc: 'charactersUnlimited',
      args: [],
    );
  }

  /// `Made with Flutter ❤ and Open Source Libraries`
  String get madeWithLoveAndFlutter {
    return Intl.message(
      'Made with Flutter ❤ and Open Source Libraries',
      name: 'madeWithLoveAndFlutter',
      desc: 'madeWithLoveAndFlutter',
      args: [],
    );
  }

  /// `or send a message to idea@xsoulspace.dev`
  String get feedbackTextWithEmail {
    return Intl.message(
      'or send a message to idea@xsoulspace.dev',
      name: 'feedbackTextWithEmail',
      desc: 'feedbackTextWithEmail',
      args: [],
    );
  }

  /// `Thank you for using this app and have a nice day, full of ideas and inspiration!:)`
  String get niceDayWish {
    return Intl.message(
      'Thank you for using this app and have a nice day, full of ideas and inspiration!:)',
      name: 'niceDayWish',
      desc: 'niceDayWish',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: 'Privacy Policy',
      args: [],
    );
  }

  /// `Terms & Conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms & Conditions',
      name: 'termsAndConditions',
      desc: 'Terms & Conditions',
      args: [],
    );
  }

  /// `Join Discord`
  String get joinDiscord {
    return Intl.message(
      'Join Discord',
      name: 'joinDiscord',
      desc: 'joinDiscord button',
      args: [],
    );
  }

  /// `Please notice`
  String get pleaseNotice {
    return Intl.message(
      'Please notice',
      name: 'pleaseNotice',
      desc: 'Please notice title',
      args: [],
    );
  }

  /// `Last Answer`
  String get appInfo {
    return Intl.message(
      'Last Answer',
      name: 'appInfo',
      desc: 'app info title',
      args: [],
    );
  }

  /// `App version: {version}, build: {buildNumber}`
  String appVersion(Object version, Object buildNumber) {
    return Intl.message(
      'App version: $version, build: $buildNumber',
      name: 'appVersion',
      desc: 'app version',
      args: [version, buildNumber],
    );
  }

  /// `Frequently used`
  String get frequentlyUsed {
    return Intl.message(
      'Frequently used',
      name: 'frequentlyUsed',
      desc: 'frequentlyUsed',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: 'app theme',
      args: [],
    );
  }

  /// `Auto`
  String get themeSystem {
    return Intl.message(
      'Auto',
      name: 'themeSystem',
      desc: 'app theme - system',
      args: [],
    );
  }

  /// `Dark`
  String get themeDark {
    return Intl.message(
      'Dark',
      name: 'themeDark',
      desc: 'app theme - dark',
      args: [],
    );
  }

  /// `Light`
  String get themeLight {
    return Intl.message(
      'Light',
      name: 'themeLight',
      desc: 'app theme - light',
      args: [],
    );
  }

  /// `Notes direction`
  String get projectsDirection {
    return Intl.message(
      'Notes direction',
      name: 'projectsDirection',
      desc: 'Projects direction',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Settings',
      args: [],
    );
  }

  /// `Note settings`
  String get noteSettings {
    return Intl.message(
      'Note settings',
      name: 'noteSettings',
      desc: 'noteSettings',
      args: [],
    );
  }

  /// `New`
  String get wordNew {
    return Intl.message(
      'New',
      name: 'wordNew',
      desc: 'New',
      args: [],
    );
  }

  /// `YES`
  String get yes {
    return Intl.message(
      'YES',
      name: 'yes',
      desc: 'yes',
      args: [],
    );
  }

  /// `No projects yet.`
  String get noProjectsYet {
    return Intl.message(
      'No projects yet.',
      name: 'noProjectsYet',
      desc: 'text if no projects created',
      args: [],
    );
  }

  /// `Create tutorial`
  String get createIdeaHelperText {
    return Intl.message(
      'Create tutorial',
      name: 'createIdeaHelperText',
      desc: 'createIdeaHelperText',
      args: [],
    );
  }

  /// `What's your idea?`
  String get whatsYourIdea {
    return Intl.message(
      'What\'s your idea?',
      name: 'whatsYourIdea',
      desc: 'What\'s your idea? label',
      args: [],
    );
  }

  /// `Last Answer`
  String get lastAnswer {
    return Intl.message(
      'Last Answer',
      name: 'lastAnswer',
      desc: 'menu title Last answer',
      args: [],
    );
  }

  /// `Idea`
  String get idea {
    return Intl.message(
      'Idea',
      name: 'idea',
      desc: 'idea name',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message(
      'Note',
      name: 'note',
      desc: 'Note name',
      args: [],
    );
  }

  /// `Answer`
  String get answer {
    return Intl.message(
      'Answer',
      name: 'answer',
      desc: 'answer input',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'popup start cancel',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: 'Close',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: 'About title',
      args: [],
    );
  }

  /// `What for?`
  String get aboutAbstractWhatFor {
    return Intl.message(
      'What for?',
      name: 'aboutAbstractWhatFor',
      desc: 'What For About Abstract',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: 'delete',
      args: [],
    );
  }

  /// `Delete this note`
  String get deleteThisNote {
    return Intl.message(
      'Delete this note',
      name: 'deleteThisNote',
      desc: 'deleteThisNote',
      args: [],
    );
  }

  /// `Are you sure?`
  String get areYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'areYouSure',
      desc: 'Are you sure',
      args: [],
    );
  }

  /// `{title} will be lost forever`
  String willBeLost(Object title) {
    return Intl.message(
      '$title will be lost forever',
      name: 'willBeLost',
      desc: 'removal warning',
      args: [title],
    );
  }

  /// `Inspiration`
  String get philosophyInspirationTitle {
    return Intl.message(
      'Inspiration',
      name: 'philosophyInspirationTitle',
      desc: 'Inspiration',
      args: [],
    );
  }

  /// `What else?`
  String get philosophyAbstractWhatElse {
    return Intl.message(
      'What else?',
      name: 'philosophyAbstractWhatElse',
      desc: 'What else',
      args: [],
    );
  }

  /// `You can use: "Five whys"`
  String get philosophyAbstractFiveWhyesWhat {
    return Intl.message(
      'You can use: "Five whys"',
      name: 'philosophyAbstractFiveWhyesWhat',
      desc: 'Method that you can use',
      args: [],
    );
  }

  /// `Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as "cause and effect" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys`
  String get philosophyAbstractFiveWhyesWhy {
    return Intl.message(
      'Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as "cause and effect" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys',
      name: 'philosophyAbstractFiveWhyesWhy',
      desc: 'Description of Five Whyes',
      args: [],
    );
  }

  /// `Because it most universal technique. It does not solid questions, as in "Five Whys", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA`
  String get philosophyAbstractPDSAWhy {
    return Intl.message(
      'Because it most universal technique. It does not solid questions, as in "Five Whys", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA',
      name: 'philosophyAbstractPDSAWhy',
      desc: 'Method that you can use',
      args: [],
    );
  }

  /// `You can use: "PDCA/PDSA (Plan-Do-Check/Study-Act): Shewhart-Deming cycle" `
  String get philosophyAbstractPDSAWhat {
    return Intl.message(
      'You can use: "PDCA/PDSA (Plan-Do-Check/Study-Act): Shewhart-Deming cycle" ',
      name: 'philosophyAbstractPDSAWhat',
      desc: 'Description of PDSA',
      args: [],
    );
  }

  /// `Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma`
  String get philosophyAbstractSixSigmaWhy {
    return Intl.message(
      'Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma',
      name: 'philosophyAbstractSixSigmaWhy',
      desc: 'Method that you can use',
      args: [],
    );
  }

  /// `You can use: "Six Sigma"`
  String get philosophyAbstractSixSigmaWhat {
    return Intl.message(
      'You can use: "Six Sigma"',
      name: 'philosophyAbstractSixSigmaWhat',
      desc: 'Description of Six Sigma',
      args: [],
    );
  }

  /// `This app is designed to solve ideas expression when it needed most; to solve complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.`
  String get aboutAbstractWhatForDescription {
    return Intl.message(
      'This app is designed to solve ideas expression when it needed most; to solve complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.',
      name: 'aboutAbstractWhatForDescription',
      desc: 'Description of About Abstract',
      args: [],
    );
  }

  /// `You can use Inspiration section to get inspiration of how this app can be used and which techniques can be applied.`
  String get aboutAbstractHowDescription {
    return Intl.message(
      'You can use Inspiration section to get inspiration of how this app can be used and which techniques can be applied.',
      name: 'aboutAbstractHowDescription',
      desc: 'Description of About Abstract How Description',
      args: [],
    );
  }

  /// `Ideas Improvements Bugs?`
  String get aboutAbstractIdeasImprovementsBugs {
    return Intl.message(
      'Ideas Improvements Bugs?',
      name: 'aboutAbstractIdeasImprovementsBugs',
      desc: 'Ideas Improvements Bugs',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
