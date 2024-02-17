import 'S.dart';

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get search => 'Search';

  @override
  String get writeAnAnswer => 'Write an answer';

  @override
  String get writeANote => 'Write a note';

  @override
  String get subscription => 'Subscription';

  @override
  String get freeSubscription => 'Free';

  @override
  String get patronSubscription => 'Patron';

  @override
  String get myAccount => 'Account';

  @override
  String get changeLog => 'What\'s new';

  @override
  String get username => 'Username';

  @override
  String get email => 'E-mail';

  @override
  String get deleteMyAccount => 'Delete Account';

  @override
  String get danger => 'Danger';

  @override
  String get loading => 'Loading';

  @override
  String get esc => 'ESC';

  @override
  String get generalSettingsFullTitle => 'General Settings';

  @override
  String get generalSettingsShortTitle => 'General';

  @override
  String get charactersLimit => 'Characters limit';

  @override
  String get charactersLimitForNewNotesDesription => 'When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.';

  @override
  String get charactersUnlimited => 'Other';

  @override
  String get madeWithLoveAndFlutter => 'Made with Flutter ❤ and Open Source Libraries';

  @override
  String get feedbackTextWithEmail => 'or send a message to idea@xsoulspace.dev';

  @override
  String get niceDayWish => 'Thank you for using this app and have a nice day, full of ideas and inspiration!:)';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get joinDiscord => 'Join Discord';

  @override
  String get pleaseNotice => 'Please notice';

  @override
  String get appInfo => 'Last Answer';

  @override
  String appVersion(Object buildNumber, Object version) {
    return 'App version: $version, build: $buildNumber';
  }

  @override
  String get frequentlyUsed => 'Frequently used';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get projectsDirection => 'Notes direction';

  @override
  String get settings => 'Settings';

  @override
  String get noteSettings => 'Note settings';

  @override
  String get wordNew => 'New';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get noProjectsYet => 'No projects yet.';

  @override
  String get createIdeaHelperText => 'Create tutorial';

  @override
  String get whatsYourIdea => 'What\'s your idea?';

  @override
  String get lastAnswer => 'Last Answer';

  @override
  String get idea => 'Idea';

  @override
  String get note => 'Note';

  @override
  String get answer => 'Answer';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get about => 'About';

  @override
  String get aboutAbstractWhatFor => 'What for?';

  @override
  String get delete => 'Delete';

  @override
  String get deleteThisNote => 'Delete this note';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String willBeLost(Object title) {
    return '$title will be lost forever';
  }

  @override
  String get philosophyInspirationTitle => 'Inspiration';

  @override
  String get philosophyAbstractWhatElse => 'What else?';

  @override
  String get philosophyAbstractFiveWhyesWhat => 'You can use: \"Five whys\"';

  @override
  String get philosophyAbstractFiveWhyesWhy => 'Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as \"cause and effect\" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys';

  @override
  String get philosophyAbstractPDSAWhy => 'Because it most universal technique. It does not solid questions, as in \"Five Whys\", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA';

  @override
  String get philosophyAbstractPDSAWhat => 'You can use: \"PDCA/PDSA (Plan-Do-Check/Study-Act): Shewhart-Deming cycle\" ';

  @override
  String get philosophyAbstractSixSigmaWhy => 'Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma';

  @override
  String get philosophyAbstractSixSigmaWhat => 'You can use: \"Six Sigma\"';

  @override
  String get aboutAbstractWhatForDescription => 'This app is designed to solve ideas expression when it needed most; to solve complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.';

  @override
  String get aboutAbstractHowDescription => 'You can use Inspiration section to get inspiration of how this app can be used and which techniques can be applied.';

  @override
  String get aboutAbstractIdeasImprovementsBugs => 'Ideas Improvements Bugs?';

  @override
  String get supporterDaysLeft => 'Supporter days left';

  @override
  String get youCanSupportAppDevelopment => 'You can start supporting the app development by watching short ad below. This will help me to improve the app and make it better.';

  @override
  String get youUsedThisAppFor => 'You used this app for';

  @override
  String get days => 'days';

  @override
  String get andHaveSupported => 'and have supported';

  @override
  String get unfortunatelyThisPlatformHasNoAbilitiesToSupport => 'Unfortunately, this platform has no abilities to support the app, yet:)';

  @override
  String get butYouCanGoTo => 'But you can go';

  @override
  String get toTheWebsite => 'to the website:)';

  @override
  String get whatSupporterDaysMeans => 'What \"Suppoter Days\" means?';

  @override
  String get supporterDaysAre => 'Supporter Days are the days given to the user of the application for supporting the project. Every time the user uses the application, one Supporter Day is deducted (only once per day, regardless of how many times the user opens the application in a day) and added to Supported Days (the total number of days the person has supported the project). If the user has never opened the application, the days are not deducted :)';

  @override
  String get supporterDaysMainFunctionality => 'The main functionality of Supporter Days does not affect anything, but in the future, they will provide the opportunity to use additional features of the application - so for me, the most important thing is that under no circumstances will the main functionality of adding/editing notes and ideas be blocked, and everything else is just bonuses if a person decides to support the project :)';

  @override
  String get toGetSupporterDays => 'To get Supporter Days, the user can press the \"watch ad\" button and after watching the advertisement (I will experiment, but for now it\'s 60 seconds), and it will reward as 7 Supporter Days.';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get adPleaseNote => 'Please note: Ad curently works only in Google Chrome and Firefox. Safari is blocking the ad, so currently it is not working.';

  @override
  String get exportImportData => 'Backup';
}
