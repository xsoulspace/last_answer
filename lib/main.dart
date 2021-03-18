import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:last_answer/abstract/Language.dart';
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
            return AppScaffold(overridenLocale: snapshot.data);
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
  final Locale _overridenLocale;
  AppScaffold({required overridenLocale}) : _overridenLocale = overridenLocale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localeListResolutionCallback: (locales, supportedLocales) {
        Locale locale = _overridenLocale;
        var isFoundLocale = AppLocalizations.delegate.isSupported(locale);

        // var isFoundLocale =supportedLocales.contains(locale);
        if (!isFoundLocale) return Locales.en;
        return locale;
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'IBM Plex Sans',
          brightness: Brightness.dark),
      home: HomeProjects(),
    );
  }
}
