import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// FIXME: when intl_translation will be realeased with null safety
// ignore: import_of_legacy_library_into_null_safe
import 'package:last_answer/localizations/main_localizations.dart';
import 'package:last_answer/screens/home_projects.dart';
import 'package:last_answer/shared_utils_models/locales_model.dart';

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
        future: systemLocale,
        builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container();
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
