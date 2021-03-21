import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:last_answer/abstract/Answer.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Language.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/models/questions_model.dart';
import 'package:last_answer/screens/home_projects.dart';
import 'package:last_answer/shared_utils_models/locales_model.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

void main() async {
  Hive.registerAdapter(AnswerAdapter());
  Hive.registerAdapter(ProjectAdapter());

  await Hive.initFlutter();
  // await Hive.deleteBoxFromDisk(HiveBoxes.projects);
  // await Hive.deleteBoxFromDisk(HiveBoxes.answers);
  await Hive.openBox<bool>(HiveBoxes.darkMode);
  await Hive.openBox<Project>(HiveBoxes.projects);
  await Hive.openBox<Answer>(HiveBoxes.answers);
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
            return ProviderInit(
              child: AppScaffold(
                  overridenLocale: snapshot.data, home: HomeProjects()),
            );
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

/// Class to init home screen, routes, locales
/// and app mode
class AppScaffold extends StatelessWidget {
  final Widget home;
  final Locale? overridenLocale;
  AppScaffold({required this.overridenLocale, required this.home});

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
              var _locale = overridenLocale;
              if (_locale == null) return Locales.en;
              var isLocaleSupported =
                  AppLocalizations.delegate.isSupported(_locale);
              if (!isLocaleSupported) return Locales.en;
              return _locale;
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
            home: home,
          );
        });
  }
}

/// Class to init providers
class ProviderInit extends StatelessWidget {
  final Widget child;
  ProviderInit({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleModel()),
        ChangeNotifierProvider(create: (_) => QuestionsModel())
      ],
      child: child,
    );
  }
}
