import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'S_en.dart';
import 'S_it.dart';
import 'S_ru.dart';

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'intl/S.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
    Locale('ru')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @writeAnAnswer.
  ///
  /// In en, this message translates to:
  /// **'Write an answer'**
  String get writeAnAnswer;

  /// No description provided for @writeANote.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get writeANote;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @freeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeSubscription;

  /// No description provided for @patronSubscription.
  ///
  /// In en, this message translates to:
  /// **'Patron'**
  String get patronSubscription;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @changeLog.
  ///
  /// In en, this message translates to:
  /// **'Change Log'**
  String get changeLog;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteMyAccount;

  /// No description provided for @danger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get danger;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @esc.
  ///
  /// In en, this message translates to:
  /// **'ESC'**
  String get esc;

  /// No description provided for @generalSettingsFullTitle.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettingsFullTitle;

  /// No description provided for @generalSettingsShortTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSettingsShortTitle;

  /// No description provided for @charactersLimit.
  ///
  /// In en, this message translates to:
  /// **'Characters limit'**
  String get charactersLimit;

  /// No description provided for @charactersLimitForNewNotesDesription.
  ///
  /// In en, this message translates to:
  /// **'When you set the limit, all new notes will have this limit. And if you will need to go-off limit for one note - just set it inside note settings.'**
  String get charactersLimitForNewNotesDesription;

  /// No description provided for @charactersUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get charactersUnlimited;

  /// No description provided for @madeWithLoveAndFlutter.
  ///
  /// In en, this message translates to:
  /// **'Made with Flutter ❤ and Open Source Libraries'**
  String get madeWithLoveAndFlutter;

  /// No description provided for @feedbackTextWithEmail.
  ///
  /// In en, this message translates to:
  /// **'or send a message to idea@xsoulspace.dev'**
  String get feedbackTextWithEmail;

  /// No description provided for @niceDayWish.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using this app and have a nice day, full of ideas and inspiration!:)'**
  String get niceDayWish;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @joinDiscord.
  ///
  /// In en, this message translates to:
  /// **'Join Discord'**
  String get joinDiscord;

  /// No description provided for @pleaseNotice.
  ///
  /// In en, this message translates to:
  /// **'Please notice'**
  String get pleaseNotice;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'Last Answer'**
  String get appInfo;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version: {version}, build: {buildNumber}'**
  String appVersion(Object buildNumber, Object version);

  /// No description provided for @frequentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Frequently used'**
  String get frequentlyUsed;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @projectsDirection.
  ///
  /// In en, this message translates to:
  /// **'Notes direction'**
  String get projectsDirection;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @noteSettings.
  ///
  /// In en, this message translates to:
  /// **'Note settings'**
  String get noteSettings;

  /// No description provided for @wordNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get wordNew;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noProjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No projects yet.'**
  String get noProjectsYet;

  /// No description provided for @createIdeaHelperText.
  ///
  /// In en, this message translates to:
  /// **'Create tutorial'**
  String get createIdeaHelperText;

  /// No description provided for @whatsYourIdea.
  ///
  /// In en, this message translates to:
  /// **'What\'s your idea?'**
  String get whatsYourIdea;

  /// No description provided for @lastAnswer.
  ///
  /// In en, this message translates to:
  /// **'Last Answer'**
  String get lastAnswer;

  /// No description provided for @idea.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get idea;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutAbstractWhatFor.
  ///
  /// In en, this message translates to:
  /// **'What for?'**
  String get aboutAbstractWhatFor;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteThisNote.
  ///
  /// In en, this message translates to:
  /// **'Delete this note'**
  String get deleteThisNote;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @willBeLost.
  ///
  /// In en, this message translates to:
  /// **'{title} will be lost forever'**
  String willBeLost(Object title);

  /// No description provided for @philosophyInspirationTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get philosophyInspirationTitle;

  /// No description provided for @philosophyAbstractWhatElse.
  ///
  /// In en, this message translates to:
  /// **'What else?'**
  String get philosophyAbstractWhatElse;

  /// No description provided for @philosophyAbstractFiveWhyesWhat.
  ///
  /// In en, this message translates to:
  /// **'You can use: \"Five whys\"'**
  String get philosophyAbstractFiveWhyesWhat;

  /// No description provided for @philosophyAbstractFiveWhyesWhy.
  ///
  /// In en, this message translates to:
  /// **'Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as \"cause and effect\" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys'**
  String get philosophyAbstractFiveWhyesWhy;

  /// No description provided for @philosophyAbstractPDSAWhy.
  ///
  /// In en, this message translates to:
  /// **'Because it most universal technique. It does not solid questions, as in \"Five Whys\", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA'**
  String get philosophyAbstractPDSAWhy;

  /// No description provided for @philosophyAbstractPDSAWhat.
  ///
  /// In en, this message translates to:
  /// **'You can use: \"PDCA/PDSA (Plan-Do-Check/Study-Act): Shewhart-Deming cycle\" '**
  String get philosophyAbstractPDSAWhat;

  /// No description provided for @philosophyAbstractSixSigmaWhy.
  ///
  /// In en, this message translates to:
  /// **'Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma'**
  String get philosophyAbstractSixSigmaWhy;

  /// No description provided for @philosophyAbstractSixSigmaWhat.
  ///
  /// In en, this message translates to:
  /// **'You can use: \"Six Sigma\"'**
  String get philosophyAbstractSixSigmaWhat;

  /// No description provided for @aboutAbstractWhatForDescription.
  ///
  /// In en, this message translates to:
  /// **'This app is designed to solve ideas expression when it needed most; to solve complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.'**
  String get aboutAbstractWhatForDescription;

  /// No description provided for @aboutAbstractHowDescription.
  ///
  /// In en, this message translates to:
  /// **'You can use Inspiration section to get inspiration of how this app can be used and which techniques can be applied.'**
  String get aboutAbstractHowDescription;

  /// No description provided for @aboutAbstractIdeasImprovementsBugs.
  ///
  /// In en, this message translates to:
  /// **'Ideas Improvements Bugs?'**
  String get aboutAbstractIdeasImprovementsBugs;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'it': return SIt();
    case 'ru': return SRu();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
