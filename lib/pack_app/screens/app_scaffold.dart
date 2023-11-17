import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/screens/app_loading_screen.dart';

class LastAnswerApp extends StatelessWidget {
  const LastAnswerApp({super.key});

  @override
  Widget build(final BuildContext context) => GlobalStatesProvider(
        builder: (final context) {
          final child = Portal(
            child: Builder(
              builder: (final context) => StateLoader(
                initializer: GlobalStatesInitializer(
                  dto: GlobalStatesInitializerDto(context: context),
                ),
                loader: const AppLoadingScreen(),
                child: const AppScaffold(),
              ),
            ),
          );

          if (isNativeDesktop) {
            return child;
          }

          return Directionality(
            // TODO(arenukvern): replace with default device textDirection
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                Container(color: AppColors.black),
                child,
              ],
            ),
          );
        },
      );
}

class AppScaffold extends StatefulHookWidget {
  const AppScaffold({super.key});

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final settings = context.select<GlobalStateNotifier, UserSettingsModel>(
      (final c) => c.value.user.settings,
    );
    return MaterialApp.router(
      /// Providing a restorationScopeId allows the Navigator built by
      /// the MaterialApp to restore the navigation stack when a user
      /// leaves and returns to the app after it has been killed while
      /// running in the background.
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (final locales, final supportedLocales) {
        final locale = settings.locale;
        if (locale == null) return null;
        if (S.delegate.isSupported(locale)) return locale;

        return null;
      },
      supportedLocales: Locales.values,
      onGenerateTitle: (final context) => S.of(context).lastAnswer,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: settings.themeMode,
      routerDelegate: routerDelegate,
      routeInformationParser: routeParser,
    );
  }
}
