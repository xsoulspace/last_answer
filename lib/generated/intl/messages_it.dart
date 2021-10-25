// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static String m0(version, buildNumber) =>
      "App version: ${version}, build: ${buildNumber}";

  static String m1(language) =>
      "${language} verrà impostata come nuova lingua. L\'app verrà ricaricata, continuare?";

  static String m2(title) => "${title} sarà perso per sempre";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Informazioni"),
        "aboutAbstractHowDescription": MessageLookupByLibrary.simpleMessage(
            "Puoi utilizzare la sezione Ispirazione per trarre ispirazione su come può essere utilizzata questa app e quali tecniche possono essere applicate."),
        "aboutAbstractIdeasImprovementsBugs":
            MessageLookupByLibrary.simpleMessage("Idee Miglioramenti Bug?"),
        "aboutAbstractWhatFor":
            MessageLookupByLibrary.simpleMessage("Per che cosa?"),
        "aboutAbstractWhatForDescription": MessageLookupByLibrary.simpleMessage(
            "Questa app è progettata per risolvere l\'espressione delle idee quando è più necessario; per risolvere la complessità e la comprensione dei pensieri durante la gestione del progetto e solo per facilitare la reciproca condivisione e comprensione delle idee."),
        "answer": MessageLookupByLibrary.simpleMessage("Risposta"),
        "appInfo": MessageLookupByLibrary.simpleMessage("Last Answer"),
        "appVersion": m0,
        "areYouSure": MessageLookupByLibrary.simpleMessage("Sei sicuro?"),
        "cancel": MessageLookupByLibrary.simpleMessage("CANCELLA"),
        "close": MessageLookupByLibrary.simpleMessage("CHIUDI"),
        "createIdeaHelperText":
            MessageLookupByLibrary.simpleMessage("Create tutorial"),
        "delete": MessageLookupByLibrary.simpleMessage("ELIMINA"),
        "feedbackTextWithEmail": MessageLookupByLibrary.simpleMessage(
            "o inviare un messaggio a idea@xsoulspace.dev"),
        "idea": MessageLookupByLibrary.simpleMessage("Idea"),
        "joinDiscord": MessageLookupByLibrary.simpleMessage("Join Discord"),
        "language": MessageLookupByLibrary.simpleMessage("Lingua"),
        "languageWillBeChanged": m1,
        "lastAnswer": MessageLookupByLibrary.simpleMessage("Last Answer"),
        "madeWithLoveAndFlutter": MessageLookupByLibrary.simpleMessage(
            "Made with Flutter ❤ and Open Source Libraries"),
        "niceDayWish": MessageLookupByLibrary.simpleMessage(
            "Grazie per aver utilizzato questa app e buona giornata, piena di idee e ispirazione!:)"),
        "noProjectsYet":
            MessageLookupByLibrary.simpleMessage("No projects yet."),
        "note": MessageLookupByLibrary.simpleMessage("Note"),
        "philosophyAbstractFiveWhyesWhat": MessageLookupByLibrary.simpleMessage(
            "Puoi usare: \"Cinque perché\""),
        "philosophyAbstractFiveWhyesWhy": MessageLookupByLibrary.simpleMessage(
            "Perché puoi usare questa tecnica se hai un problema o un\'idea, che deve essere esplorata più a fondo. Metodo di esplorazione spesso chiamato anche esplorazione \"causa ed effetto\". Vedi di più sulla tecnica su wiki: https://en.wikipedia.org/wiki/Five_whys"),
        "philosophyAbstractPDSAWhat": MessageLookupByLibrary.simpleMessage(
            "Puoi usare: \"PDCA/PDSA (Plan-Do-Check/Study-Act): ciclo Shewhart-Deming\" "),
        "philosophyAbstractPDSAWhy": MessageLookupByLibrary.simpleMessage(
            "Perché è la tecnica più universale. Non pone domande solide, come in \"Cinque perché\", ma il metodo può aiutare non solo a fare l\'esplorazione di idee, ma a comprendere i problemi dell\'intera area. Vedi di più sulla tecnica su wiki: https://en.wikipedia.org/wiki/PDCA"),
        "philosophyAbstractSixSigmaWhat":
            MessageLookupByLibrary.simpleMessage("Puoi usare: \"Six Sigma\""),
        "philosophyAbstractSixSigmaWhy": MessageLookupByLibrary.simpleMessage(
            "Perché se il tuo problema o idea ha origine nella produzione/trasporto, questo metodo aiuterà sicuramente a sviluppare o migliorare il processo o il prodotto aziendale. Vedi di più sulla tecnica su wiki: https://en.wikipedia.org/wiki/Six_Sigma"),
        "philosophyAbstractWhatElse":
            MessageLookupByLibrary.simpleMessage("Cos\'altro?"),
        "philosophyInspirationTitle":
            MessageLookupByLibrary.simpleMessage("Ispirazione"),
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
        "writeANote": MessageLookupByLibrary.simpleMessage("Write a note"),
        "writeAnAnswer":
            MessageLookupByLibrary.simpleMessage("Write an answer"),
        "yes": MessageLookupByLibrary.simpleMessage("Si")
      };
}
