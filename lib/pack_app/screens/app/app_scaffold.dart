import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/pack_app/navigation/locations/home_location.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatefulHookWidget {
  const AppScaffold({final Key? key}) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final routerDelegate = BeamerDelegate(
    locationBuilder: HomeLocation.builder,
  );
  final routeParser = BeamerParser();

  @override
  Widget build(final BuildContext context) {
    final settings = context.watch<GeneralSettingsController>();

    return AnimatedBuilder(
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
            FormBuilderLocalizations.delegate,
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

          theme: lightThemeData,
          darkTheme: darkThemeData,
          themeMode: settings.themeMode,

          routerDelegate: routerDelegate,
          routeInformationParser: routeParser,
        );
      },
    );
  }
}
