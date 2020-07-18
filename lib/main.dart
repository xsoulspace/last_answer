import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:howtosolvethequest/models/PagesModel.dart';
import 'package:howtosolvethequest/models/QuestionsModel.dart';
import 'package:howtosolvethequest/screens/MenuScreen.dart';
import 'package:howtosolvethequest/screens/ScaffoldAppBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ThemeColors {
  static final lightAccent = Colors.lightGreen[50];
}

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
    print(_localeOverrideDelegate.overridenLocale);
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => LocaleModel()),
      ChangeNotifierProvider(create: (context) => AnswersModel()),
      ChangeNotifierProvider(create: (context) => QuestionsModel()),
      ChangeNotifierProvider(create: (context) => PagesModel()),
    ], child: AppScaffold(_localeOverrideDelegate));
  }

  @override
  Widget build(BuildContext context) {
    Future<Locale> systemLocale = LocaleModel.loadSavedLocale();

    return FutureBuilder(
        future: systemLocale, // stream data to listen for change
        builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
          // print('connection done ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.done) {
            // print('connection done ${snapshot.data.toString()}');
            MainLocalizationsDelegate _localeOverrideDelegate =
                MainLocalizationsDelegate(snapshot.data);
            return scaffoldApp(context, _localeOverrideDelegate);
          } else {
            return _circularSpinner();
          }
        });
  }

  Widget _circularSpinner() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class AppScaffold extends StatelessWidget {
  final MainLocalizationsDelegate _overridenLocaleDelegate;
  AppScaffold(this._overridenLocaleDelegate);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localeListResolutionCallback: (locales, supportedLocales) {
        Locale locale = _overridenLocaleDelegate.overridenLocale;
        var isFoundLocale = _overridenLocaleDelegate.isSupported(locale);
        print(supportedLocales.toString());
        print(locales.toString());

        // var isFoundLocale =supportedLocales.contains(locale);
        print(isFoundLocale);
        if (!isFoundLocale) {
          return LocaleModelConsts.localeEN;
        }
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
        LocaleModelConsts.localeRU, // Russian
        LocaleModelConsts.localeEN, // English
      ],
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.lightGreen[800],
        accentColor: Colors.lightGreen[800],

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
        '/': (context) => ScaffoldAppBar(),
        '/menu': (context) => MenuScreen(),
      },
    );
  }
}
