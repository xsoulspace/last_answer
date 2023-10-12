// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lastanswer/generated/intl/messages_all.dart';

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
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',);
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(final Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((final _) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(final BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',);
    return instance!;
  }

  static S? maybeOf(final BuildContext context) => Localizations.of<S>(context, S);

  /// `Language`
  String get language => Intl.message(
      'Language',
      name: 'language',
      desc: 'menu title language',
      args: [],
    );

  /// `Search`
  String get search => Intl.message(
      'Search',
      name: 'search',
      desc: 'Search',
      args: [],
    );

  /// `Write an answer`
  String get writeAnAnswer => Intl.message(
      'Write an answer',
      name: 'writeAnAnswer',
      desc: 'writeAnAnswer',
      args: [],
    );

  /// `Write a note`
  String get writeANote => Intl.message(
      'Write a note',
      name: 'writeANote',
      desc: 'writeANote',
      args: [],
    );

  /// `Subscription`
  String get subscription => Intl.message(
      'Subscription',
      name: 'subscription',
      desc: 'subscription',
      args: [],
    );

  /// `Free`
  String get freeSubscription => Intl.message(
      'Free',
      name: 'freeSubscription',
      desc: 'free Subscription',
      args: [],
    );

  /// `Patron`
  String get patronSubscription => Intl.message(
      'Patron',
      name: 'patronSubscription',
      desc: 'patronSubscription',
      args: [],
    );

  /// `My Account`
  String get myAccount => Intl.message(
      'My Account',
      name: 'myAccount',
      desc: 'myAccount',
      args: [],
    );

  /// `Change Log`
  String get changeLog => Intl.message(
      'Change Log',
      name: 'changeLog',
      desc: 'changeLog',
      args: [],
    );

  /// `Username`
  String get username => Intl.message(
      'Username',
      name: 'username',
      desc: 'username',
      args: [],
    );

  /// `E-mail`
  String get email => Intl.message(
      'E-mail',
      name: 'email',
      desc: 'email',
      args: [],
    );

  /// `Delete Account`
  String get deleteMyAccount => Intl.message(
      'Delete Account',
      name: 'deleteMyAccount',
      desc: 'deleteMyAccount',
      args: [],
    );

  /// `Danger`
  String get danger => Intl.message(
      'Danger',
      name: 'danger',
      desc: 'danger',
      args: [],
    );

  /// `ESC`
  String get esc => Intl.message(
      'ESC',
      name: 'esc',
      desc: 'esc',
      args: [],
    );

  /// `General Settings`
  String get generalSettingsFullTitle => Intl.message(
      'General Settings',
      name: 'generalSettingsFullTitle',
      desc: 'generalSettingsFullTitle',
      args: [],
    );

  /// `General`
  String get generalSettingsShortTitle => Intl.message(
      'General',
      name: 'generalSettingsShortTitle',
      desc: 'generalSettingsShortTitle',
      args: [],
    );

  /// `Characters limit`
  String get charactersLimit => Intl.message(
      'Characters limit',
      name: 'charactersLimit',
      desc: 'charactersLimit',
      args: [],
    );

  /// `When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.`
  String get charactersLimitForNewNotesDesription => Intl.message(
      'When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.',
      name: 'charactersLimitForNewNotesDesription',
      desc:
          'When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.',
      args: [],
    );

  /// `Other`
  String get charactersUnlimited => Intl.message(
      'Other',
      name: 'charactersUnlimited',
      desc: 'charactersUnlimited',
      args: [],
    );

  /// `Made with Flutter ❤ and Open Source Libraries`
  String get madeWithLoveAndFlutter => Intl.message(
      'Made with Flutter ❤ and Open Source Libraries',
      name: 'madeWithLoveAndFlutter',
      desc: 'madeWithLoveAndFlutter',
      args: [],
    );

  /// `or send a message to idea@xsoulspace.dev`
  String get feedbackTextWithEmail => Intl.message(
      'or send a message to idea@xsoulspace.dev',
      name: 'feedbackTextWithEmail',
      desc: 'feedbackTextWithEmail',
      args: [],
    );

  /// `Thank you for using this app and have a nice day, full of ideas and inspiration!:)`
  String get niceDayWish => Intl.message(
      'Thank you for using this app and have a nice day, full of ideas and inspiration!:)',
      name: 'niceDayWish',
      desc: 'niceDayWish',
      args: [],
    );

  /// `Privacy Policy`
  String get privacyPolicy => Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: 'Privacy Policy',
      args: [],
    );

  /// `Terms & Conditions`
  String get termsAndConditions => Intl.message(
      'Terms & Conditions',
      name: 'termsAndConditions',
      desc: 'Terms & Conditions',
      args: [],
    );

  /// `Join Discord`
  String get joinDiscord => Intl.message(
      'Join Discord',
      name: 'joinDiscord',
      desc: 'joinDiscord button',
      args: [],
    );

  /// `Please notice`
  String get pleaseNotice => Intl.message(
      'Please notice',
      name: 'pleaseNotice',
      desc: 'Please notice title',
      args: [],
    );

  /// `Last Answer`
  String get appInfo => Intl.message(
      'Last Answer',
      name: 'appInfo',
      desc: 'app info title',
      args: [],
    );

  /// `App version: {version}, build: {buildNumber}`
  String appVersion(final Object version, final Object buildNumber) => Intl.message(
      'App version: $version, build: $buildNumber',
      name: 'appVersion',
      desc: 'app version',
      args: [version, buildNumber],
    );

  /// `Frequently used`
  String get frequentlyUsed => Intl.message(
      'Frequently used',
      name: 'frequentlyUsed',
      desc: 'frequentlyUsed',
      args: [],
    );

  /// `Theme`
  String get theme => Intl.message(
      'Theme',
      name: 'theme',
      desc: 'app theme',
      args: [],
    );

  /// `Auto`
  String get themeSystem => Intl.message(
      'Auto',
      name: 'themeSystem',
      desc: 'app theme - system',
      args: [],
    );

  /// `Dark`
  String get themeDark => Intl.message(
      'Dark',
      name: 'themeDark',
      desc: 'app theme - dark',
      args: [],
    );

  /// `Light`
  String get themeLight => Intl.message(
      'Light',
      name: 'themeLight',
      desc: 'app theme - light',
      args: [],
    );

  /// `Notes direction`
  String get projectsDirection => Intl.message(
      'Notes direction',
      name: 'projectsDirection',
      desc: 'Projects direction',
      args: [],
    );

  /// `Settings`
  String get settings => Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Settings',
      args: [],
    );

  /// `Note settings`
  String get noteSettings => Intl.message(
      'Note settings',
      name: 'noteSettings',
      desc: 'noteSettings',
      args: [],
    );

  /// `New`
  String get wordNew => Intl.message(
      'New',
      name: 'wordNew',
      desc: 'New',
      args: [],
    );

  /// `YES`
  String get yes => Intl.message(
      'YES',
      name: 'yes',
      desc: 'yes',
      args: [],
    );

  /// `No projects yet.`
  String get noProjectsYet => Intl.message(
      'No projects yet.',
      name: 'noProjectsYet',
      desc: 'text if no projects created',
      args: [],
    );

  /// `Create tutorial`
  String get createIdeaHelperText => Intl.message(
      'Create tutorial',
      name: 'createIdeaHelperText',
      desc: 'createIdeaHelperText',
      args: [],
    );

  /// `What's your idea?`
  String get whatsYourIdea => Intl.message(
      'What\'s your idea?',
      name: 'whatsYourIdea',
      desc: 'What\'s your idea? label',
      args: [],
    );

  /// `Last Answer`
  String get lastAnswer => Intl.message(
      'Last Answer',
      name: 'lastAnswer',
      desc: 'menu title Last answer',
      args: [],
    );

  /// `Idea`
  String get idea => Intl.message(
      'Idea',
      name: 'idea',
      desc: 'idea name',
      args: [],
    );

  /// `Note`
  String get note => Intl.message(
      'Note',
      name: 'note',
      desc: 'Note name',
      args: [],
    );

  /// `Answer`
  String get answer => Intl.message(
      'Answer',
      name: 'answer',
      desc: 'answer input',
      args: [],
    );

  /// `Cancel`
  String get cancel => Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'popup start cancel',
      args: [],
    );

  /// `Close`
  String get close => Intl.message(
      'Close',
      name: 'close',
      desc: 'Close',
      args: [],
    );

  /// `About`
  String get about => Intl.message(
      'About',
      name: 'about',
      desc: 'About title',
      args: [],
    );

  /// `What for?`
  String get aboutAbstractWhatFor => Intl.message(
      'What for?',
      name: 'aboutAbstractWhatFor',
      desc: 'What For About Abstract',
      args: [],
    );

  /// `Delete`
  String get delete => Intl.message(
      'Delete',
      name: 'delete',
      desc: 'delete',
      args: [],
    );

  /// `Delete this note`
  String get deleteThisNote => Intl.message(
      'Delete this note',
      name: 'deleteThisNote',
      desc: 'deleteThisNote',
      args: [],
    );

  /// `Are you sure?`
  String get areYouSure => Intl.message(
      'Are you sure?',
      name: 'areYouSure',
      desc: 'Are you sure',
      args: [],
    );

  /// `{title} will be lost forever`
  String willBeLost(final Object title) => Intl.message(
      '$title will be lost forever',
      name: 'willBeLost',
      desc: 'removal warning',
      args: [title],
    );

  /// `Inspiration`
  String get philosophyInspirationTitle => Intl.message(
      'Inspiration',
      name: 'philosophyInspirationTitle',
      desc: 'Inspiration',
      args: [],
    );

  /// `What else?`
  String get philosophyAbstractWhatElse => Intl.message(
      'What else?',
      name: 'philosophyAbstractWhatElse',
      desc: 'What else',
      args: [],
    );

  /// `You can use: "Five whys"`
  String get philosophyAbstractFiveWhyesWhat => Intl.message(
      'You can use: "Five whys"',
      name: 'philosophyAbstractFiveWhyesWhat',
      desc: 'Method that you can use',
      args: [],
    );

  /// `Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as "cause and effect" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys`
  String get philosophyAbstractFiveWhyesWhy => Intl.message(
      'Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as "cause and effect" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys',
      name: 'philosophyAbstractFiveWhyesWhy',
      desc: 'Description of Five Whyes',
      args: [],
    );

  /// `Because it most universal technique. It does not solid questions, as in "Five Whys", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA`
  String get philosophyAbstractPDSAWhy => Intl.message(
      'Because it most universal technique. It does not solid questions, as in "Five Whys", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA',
      name: 'philosophyAbstractPDSAWhy',
      desc: 'Method that you can use',
      args: [],
    );

  /// `You can use: "PDCA/PDSA (Plan-Do-Check/Study-Act): Shewhart-Deming cycle" `
  String get philosophyAbstractPDSAWhat => Intl.message(
      'You can use: "PDCA/PDSA (Plan-Do-Check/Study-Act): Shewhart-Deming cycle" ',
      name: 'philosophyAbstractPDSAWhat',
      desc: 'Description of PDSA',
      args: [],
    );

  /// `Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma`
  String get philosophyAbstractSixSigmaWhy => Intl.message(
      'Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma',
      name: 'philosophyAbstractSixSigmaWhy',
      desc: 'Method that you can use',
      args: [],
    );

  /// `You can use: "Six Sigma"`
  String get philosophyAbstractSixSigmaWhat => Intl.message(
      'You can use: "Six Sigma"',
      name: 'philosophyAbstractSixSigmaWhat',
      desc: 'Description of Six Sigma',
      args: [],
    );

  /// `This app is designed to solve ideas expression when it needed most; to solve complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.`
  String get aboutAbstractWhatForDescription => Intl.message(
      'This app is designed to solve ideas expression when it needed most; to solve complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.',
      name: 'aboutAbstractWhatForDescription',
      desc: 'Description of About Abstract',
      args: [],
    );

  /// `You can use Inspiration section to get inspiration of how this app can be used and which techniques can be applied.`
  String get aboutAbstractHowDescription => Intl.message(
      'You can use Inspiration section to get inspiration of how this app can be used and which techniques can be applied.',
      name: 'aboutAbstractHowDescription',
      desc: 'Description of About Abstract How Description',
      args: [],
    );

  /// `Ideas Improvements Bugs?`
  String get aboutAbstractIdeasImprovementsBugs => Intl.message(
      'Ideas Improvements Bugs?',
      name: 'aboutAbstractIdeasImprovementsBugs',
      desc: 'Ideas Improvements Bugs',
      args: [],
    );
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales => const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];

  @override
  bool isSupported(final Locale locale) => _isSupported(locale);
  @override
  Future<S> load(final Locale locale) => S.load(locale);
  @override
  bool shouldReload(final AppLocalizationDelegate old) => false;

  bool _isSupported(final Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
