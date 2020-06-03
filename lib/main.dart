import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:howtosolvethequest/models/QuestionsModel.dart';
import 'package:howtosolvethequest/screens/AnswersScreen.dart';
import 'package:howtosolvethequest/screens/AskScreen.dart';
import 'package:howtosolvethequest/screens/MenuScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  if (!kIsWeb && Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  runApp(HowToSolveTheQuest());
}

class HowToSolveTheQuest extends StatefulWidget {
  @override
  _HowToSolveTheQuestState createState() => _HowToSolveTheQuestState();
}

Future<Locale> systemLocale = LocaleModel.loadSavedLocale();

class _HowToSolveTheQuestState extends State<HowToSolveTheQuest> {
  MainLocalizationsDelegate _localeOverrideDelegate =
      MainLocalizationsDelegate(systemLocale);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AnswersModel()),
        ChangeNotifierProvider(create: (context) => QuestionsModel()),
        ChangeNotifierProvider(create: (context) => LocaleModel()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          _localeOverrideDelegate
        ],
        supportedLocales: [
          const Locale('en', 'EN'), // English
          const Locale('ru', 'RU'), // Russian
        ],
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.dark,
          primaryColor: Colors.lightGreen[800],
          accentColor: Colors.lightGreen[50],
          buttonColor: Colors.lightGreen[900],
          // Define the default font family.
          fontFamily: 'Georgia',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          // textTheme: TextTheme(
          //   headline5: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          //   headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          //   bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          // ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AskScreen(),
          '/menu': (context) => MenuScreen(),
          '/answers': (context) => AnswersScreen(),
        },
      ),
    );
  }
}
