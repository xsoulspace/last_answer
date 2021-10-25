// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(version, buildNumber) =>
      "App version: ${version}, build: ${buildNumber}";

  static String m1(language) =>
      "${language} will be set as a new language. The app will be reloaded, continue?";

  static String m2(title) => "${title} will be lost forever";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "aboutAbstractHowDescription": MessageLookupByLibrary.simpleMessage(
            "You can use Inspiration section to get inspiration of how this app can be used and which techniques can be applied."),
        "aboutAbstractIdeasImprovementsBugs":
            MessageLookupByLibrary.simpleMessage("Ideas Improvements Bugs?"),
        "aboutAbstractWhatFor":
            MessageLookupByLibrary.simpleMessage("What for?"),
        "aboutAbstractWhatForDescription": MessageLookupByLibrary.simpleMessage(
            "This app is designed to solve ideas expression when it needed most; to solve complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding."),
        "answer": MessageLookupByLibrary.simpleMessage("Answer"),
        "appInfo": MessageLookupByLibrary.simpleMessage("Last Answer"),
        "appVersion": m0,
        "areYouSure": MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "cancel": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "close": MessageLookupByLibrary.simpleMessage("CLOSE"),
        "createIdeaHelperText":
            MessageLookupByLibrary.simpleMessage("Create tutorial"),
        "delete": MessageLookupByLibrary.simpleMessage("DELETE"),
        "feedbackTextWithEmail": MessageLookupByLibrary.simpleMessage(
            "or send a message to idea@xsoulspace.dev"),
        "idea": MessageLookupByLibrary.simpleMessage("Idea"),
        "joinDiscord": MessageLookupByLibrary.simpleMessage("Join Discord"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "languageWillBeChanged": m1,
        "lastAnswer": MessageLookupByLibrary.simpleMessage("Last Answer"),
        "madeWithLoveAndFlutter": MessageLookupByLibrary.simpleMessage(
            "Made with Flutter ❤ and Open Source Libraries"),
        "niceDayWish": MessageLookupByLibrary.simpleMessage(
            "Thank you for using this app and have a nice day, full of ideas and inspiration!:)"),
        "noProjectsYet":
            MessageLookupByLibrary.simpleMessage("No projects yet."),
        "note": MessageLookupByLibrary.simpleMessage("Note"),
        "philosophyAbstractFiveWhyesWhat":
            MessageLookupByLibrary.simpleMessage("You can use: \"Five whys\""),
        "philosophyAbstractFiveWhyesWhy": MessageLookupByLibrary.simpleMessage(
            "Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as \"cause and effect\" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys"),
        "philosophyAbstractPDSAWhat": MessageLookupByLibrary.simpleMessage(
            "You can use: \"PDCA/PDSA (Plan-Do-Check/Study-Act): Shewhart-Deming cycle\" "),
        "philosophyAbstractPDSAWhy": MessageLookupByLibrary.simpleMessage(
            "Because it most universal technique. It does not solid questions, as in \"Five Whys\", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA"),
        "philosophyAbstractSixSigmaWhat":
            MessageLookupByLibrary.simpleMessage("You can use: \"Six Sigma\""),
        "philosophyAbstractSixSigmaWhy": MessageLookupByLibrary.simpleMessage(
            "Because if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma"),
        "philosophyAbstractWhatElse":
            MessageLookupByLibrary.simpleMessage("What else?"),
        "philosophyInspirationTitle":
            MessageLookupByLibrary.simpleMessage("Inspiration"),
        "pleaseNotice": MessageLookupByLibrary.simpleMessage("Please notice"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeSystem": MessageLookupByLibrary.simpleMessage("System"),
        "versionLimitations": MessageLookupByLibrary.simpleMessage(
            "This version may not have all features of previous version, such as languages and help and etc, but they will return in the next updates - stay tuned:)"),
        "whatsYourIdea":
            MessageLookupByLibrary.simpleMessage("What\'s your idea?"),
        "willBeLost": m2,
        "yes": MessageLookupByLibrary.simpleMessage("YES")
      };
}
