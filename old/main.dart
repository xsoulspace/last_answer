import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/answer.dart';
import 'package:lastanswer/abstract/basic_project.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';
import 'package:lastanswer/abstract/language.dart';
import 'package:lastanswer/library/theme.dart';
import 'package:lastanswer/models/questions_model.dart';
import 'package:lastanswer/screens/home_projects.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:lastanswer/widgets/restarter.dart';
import 'package:lastanswer/widgets/spinner.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

Future<void> main() async {
  Hive.registerAdapter(AnswerAdapter());
  Hive.registerAdapter(ProjectAdapter());
  if (!kIsWeb && Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(
    Restarter(
      child: HowToSolveTheQuest(),
    ),
  );
}

class HowToSolveTheQuest extends StatefulWidget {
  @override
  _HowToSolveTheQuestState createState() => _HowToSolveTheQuestState();
}

class _HowToSolveTheQuestState extends State<HowToSolveTheQuest> {
  _HowToSolveTheQuestState();
  // Future<Locale> _systemLocale =
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: (() async {
        await Hive.initFlutter();
        // await Hive.deleteBoxFromDisk(HiveBoxes.projects);
        // await Hive.deleteBoxFromDisk(HiveBoxes.answers);
        await Hive.openBox<bool>(HiveBoxes.darkMode);
        await Hive.openBox<Project>(HiveBoxes.projects);
        await Hive.openBox<Answer>(HiveBoxes.answers);
        return LocaleModel.loadSavedLocale();
      })(),
      builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final locale = (() {
            final _locale = snapshot.data;
            if (_locale == null) return Locales.en;
            final isLocaleSupported =
                AppLocalizations.delegate.isSupported(_locale);
            if (!isLocaleSupported) return Locales.en;

            return _locale;
          })();
          return ProviderInit(
            locale: locale,
            child: AppScaffold(
              localeListResolutionCallback: (locales, supportedLocales) =>
                  locale,
              home: const HomeProjects(),
            ),
          );
        } else {
          return spinner;
        }
      },
    );
  }
}

/// Class to init home screen, routes, locales
/// and app mode
class AppScaffold extends StatelessWidget {
  final Widget home;
  final Locale? Function(List<Locale>?, Iterable<Locale>)?
      localeListResolutionCallback;
  const AppScaffold({
    required this.home,
    this.localeListResolutionCallback,
  });
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<bool>(HiveBoxes.darkMode).listenable(),
      builder: (context, Box<bool> box, widget) {
        final isDark =
            box.get(BoxDarkMode.isDark, defaultValue: false) ?? false;
        final resolvedThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        return MaterialApp(
          localeListResolutionCallback: localeListResolutionCallback,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: resolvedThemeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: home,
        );
      },
    );
  }
}

/// Class to init providers
class ProviderInit extends StatelessWidget {
  final Widget child;
  final Locale locale;
  const ProviderInit({
    required this.child,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleModel.fromLocale(
            locale: locale,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => QuestionsModel(),
        )
      ],
      child: child,
    );
  }
}
