import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:ui_locale/ui_locale.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    required this.goRouter,
    super.key,
  });
  final GoRouter goRouter;
  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late final UiThemeScheme _themeScheme = UiThemeScheme.m3(context);
  @override
  void dispose() {
    widget.goRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => MaterialApp.router(
        routerConfig: widget.goRouter,
        builder: (final context, final child) => Builder(
          builder: (final context) {
            context.read<L10nScope>().s = S.of(context);

            return UiTheme(
              scheme: _themeScheme,
              child: child!,
            );
          },
        ),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          ...S.localizationsDelegates,
          FormBuilderLocalizations.delegate,
        ],
        supportedLocales: S.supportedLocales,
        theme: ThemeData.from(
          colorScheme: AppColorSchemes.brand().light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData.from(
          colorScheme: AppColorSchemes.brand().dark,
          useMaterial3: true,
        ),
      );
}
