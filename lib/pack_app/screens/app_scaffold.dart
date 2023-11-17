import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:blur/blur.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_note/note_screen.dart';
import 'package:lastanswer/pack_note/note_view.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class LastAnswerApp extends StatelessWidget {
  const LastAnswerApp({super.key});

  @override
  Widget build(final BuildContext context) => AppStateProvider(
        builder: (final _) => const AppScaffold(),
      );
}

class AppScaffold extends StatefulHookWidget {
  const AppScaffold({super.key});

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
    final settings = context.read<GeneralSettingsController>();

    return RouteStateScope(
      notifier: routeState,
      child: AnimatedBuilder(
        animation: settings,
        builder: (final context, final child) => MaterialApp.router(
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
          localeListResolutionCallback:
              (final locales, final supportedLocales) {
            final locale = settings.locale;
            if (locale == null) return null;
            if (S.delegate.isSupported(locale)) return locale;

            return null;
          },
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
        ),
      ),
    );
  }
}
