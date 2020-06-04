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

void main() async {
  if (!kIsWeb && Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(HowToSolveTheQuest());
}

class HowToSolveTheQuest extends StatefulWidget {
  @override
  _HowToSolveTheQuestState createState() => _HowToSolveTheQuestState();
}

class _HowToSolveTheQuestState extends State<HowToSolveTheQuest> {
  _HowToSolveTheQuestState();

  scaffoldApp(
      BuildContext context, MainLocalizationsDelegate _localeOverrideDelegate) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => LocaleModel()),
      ChangeNotifierProvider(create: (context) => AnswersModel()),
      ChangeNotifierProvider(create: (context) => QuestionsModel()),
    ], child: AppScaffold(_localeOverrideDelegate));
  }

  @override
  Widget build(BuildContext context) {
    Future<Locale> systemLocale = LocaleModel.loadSavedLocale();
    
    return FutureBuilder(
        future: systemLocale, // stream data to listen for change
        builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
          print('connection done ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.done) {
            print('connection done ${snapshot.data.toString()}');
            MainLocalizationsDelegate _localeOverrideDelegate =
                MainLocalizationsDelegate(snapshot.data);
            return scaffoldApp(context, _localeOverrideDelegate);
          } else {
            // TODO: make loader

            return MaterialApp(
              builder: (context, child) => Scaffold(
                  backgroundColor: Colors.white,
                  body: Column(
                    children: [CircularProgressIndicator()],
                  )),
            );
          }
        });
  }
}

class AppScaffold extends StatelessWidget {
  final MainLocalizationsDelegate _overridenLocaleDelegate;
  AppScaffold(this._overridenLocaleDelegate);

  @override
  Widget build(BuildContext context) {
    AnswersModel answersModel = Provider.of<AnswersModel>(context);
    answersModel.ini();
    
    return MaterialApp(
      localeListResolutionCallback: (locales, supportedLocales) {
        LocaleModel localeModel = Provider.of<LocaleModel>(context);
        Locale locale = _overridenLocaleDelegate.overridenLocale;
        localeModel.notifyAndSetLang(locale);
        return locale;
      },
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        _overridenLocaleDelegate,
      ],
      supportedLocales: [
        const Locale('ru', 'RU'), // Russian
        const Locale('en', 'EN'), // English
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
    );
  }
}
