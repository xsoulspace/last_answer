import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Language.dart';
import 'package:last_answer/screens/home_projects.dart';
import 'package:last_answer/shared_utils_models/locales_model.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<bool>(HiveBoxes.darkMode);

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
  Future<Locale> _systemLocale = LocaleModel.loadSavedLocale();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _systemLocale,
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
    return ValueListenableBuilder(
        valueListenable: Hive.box<bool>(HiveBoxes.darkMode).listenable(),
        builder: (context, Box<bool> box, widget) {
          var isDark =
              box.get(BoxDarkMode.isDark, defaultValue: false) ?? false;
          var resolvedThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          return MaterialApp(
              localeListResolutionCallback: (locales, supportedLocales) {
                Locale locale = _overridenLocale;
                var isLocaleSupported =
                    AppLocalizations.delegate.isSupported(locale);
                if (!isLocaleSupported) return Locales.en;
                return locale;
              },
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: resolvedThemeMode,
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  fontFamily: 'IBM Plex Sans',
                  brightness: Brightness.light),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                fontFamily: 'IBM Plex Sans',
              ),
              home: HomeProjects());
        });
  }
}
