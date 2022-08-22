import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:la_core/la_core.dart';
import 'package:la_design_core/la_design_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/screens/app/app_services_provider.dart';
import 'package:lastanswer/pack_app/states/global_state_initializer.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';

part 'app_scaffold_state.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Portal(
      child: AppServicesProvider(
        child: RouterScaffold(
          builder: (final context, final parser) => AppScaffoldBuilder(
            routeParser: parser,
          ),
        ),
      ),
    );
  }
}

class RouterScaffold extends HookWidget {
  const RouterScaffold({
    required this.builder,
    final Key? key,
  }) : super(key: key);
  final Widget Function(BuildContext context, TemplateRouteParser parser)
      builder;
  @override
  Widget build(final BuildContext context) {
    final state = useAppScaffoldState();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RouteState>(
          create: (final context) => state.routeState,
        ),
        Provider<AppRouterController>(
          create: (final context) => AppRouterController.use(context.read),
        ),
      ],
      builder: (final context, final child) =>
          builder(context, state.routeParser),
    );
  }
}

class AppScaffoldBuilder extends HookWidget {
  const AppScaffoldBuilder({required this.routeParser, final Key? key})
      : super(key: key);
  final TemplateRouteParser routeParser;
  @override
  Widget build(final BuildContext context) {
    final state = useAppScaffoldBodyState(context.read);
    final settings = context.watch<GeneralSettingsController>();

    return AnimatedBuilder(
      animation: settings,
      builder: (final context, final child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,

          theme: lightThemeData,
          darkTheme: darkThemeData,
          themeMode: settings.themeMode,
          routeInformationParser: routeParser,
          routerDelegate: state.routerDelegate,

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
          builder: (final context, final child) {
            return UiTheme(
              scheme: UiThemeScheme.m3(context),
              child: StateLoader(
                initializer: GlobalStateInitializer(),
                loader: const LoadingScreen(),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
