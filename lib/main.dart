import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// FIXME: when intl_translation will be realeased with null safety
// ignore: import_of_legacy_library_into_null_safe
import 'package:last_answer/localizations/MainLocalizations.dart';
import 'package:last_answer/models/Projects.dart';
import 'package:last_answer/screens/HomeProjects.dart';
import 'package:provider/provider.dart';

import 'models/AnswersModel.dart';
import 'models/LocaleModel.dart';
import 'models/QuestionsModel.dart';

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
                MainLocalizationsDelegate(
                    snapshot.data ?? LocaleModelConsts.localeEN);
            return MultiProvider(providers: [
              ChangeNotifierProvider(create: (context) => LocaleModel()),
              ChangeNotifierProvider(create: (context) => AnswersModel()),
              ChangeNotifierProvider(create: (context) => QuestionsModel()),
              ChangeNotifierProvider(create: (context) => ProjectsModel()),
            ], child: AppScaffold(_localeOverrideDelegate));
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

        // var isFoundLocale =supportedLocales.contains(locale);
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
          primarySwatch: Colors.blue,
          fontFamily: 'IBM Plex Sans',
          brightness: Brightness.dark),
      home: HomeProjects(),
    );
  }
}
