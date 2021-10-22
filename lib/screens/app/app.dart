library app_provider;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/providers/providers.dart';
import 'package:lastanswer/screens/app_navigator/app_navigator.dart';
import 'package:lastanswer/screens/settings/settings.dart';
import 'package:lastanswer/utils/utils.dart';

part 'app_store_initializer.dart';
part 'idea_questions_initializer.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({final Key? key}) : super(key: key);
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  static final _settings =
      SettingsController(settingsService: SettingsService());

  @override
  Widget build(final BuildContext context) {
    return ProviderScope(
      child: SettingsStateScope(
        notifier: _settings,
        child: const AppStoreInitializer(
          child: AppScaffold(),
        ),
      ),
    );
  }
}

class AppScaffold extends StatefulHookWidget {
  const AppScaffold({final Key? key}) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late final RouteState routeState;
  late final SimpleRouterDelegate routerDelegate;
  late final TemplateRouteParser routeParser;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    routeParser = TemplateRouteParser(
      allowedPaths: AppRoutesName.values,
      guards: [],
    );

    routeState = RouteState(routeParser);

    routerDelegate = SimpleRouterDelegate(
      routeState: routeState,
      navigatorKey: navigatorKey,
      builder: (final context) => AppNavigator(
        navigatorKey: navigatorKey,
        routeState: routeState,
      ),
    );

    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final settings = SettingsStateScope.of(context);
    return RouteStateScope(
      notifier: routeState,
      child: AnimatedBuilder(
        animation: settings,
        builder: (final context, final child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,

            /// Providing a restorationScopeId allows the Navigator built by
            /// the MaterialApp to restore the navigation stack when a user
            /// leaves and returns to the app after it has been killed while
            /// running in the background.
            restorationScopeId: 'app',

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: Locales.values,

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.
            onGenerateTitle: (final context) => S.of(context).lastAnswer,

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: lightThemeData,
            darkTheme: darkThemeData,
            themeMode: settings.themeMode,

            routerDelegate: routerDelegate,
            routeInformationParser: routeParser,
          );
        },
      ),
    );
  }
}
