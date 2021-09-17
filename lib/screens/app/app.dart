import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/utils/utils.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({final Key? key}) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final _routerDelegate = SimpleRouterDelegate(
    builder: (final context) {},
    navigatorKey: null,
    routeState: null,
  );
  final _routeInformationParser = TemplateRouteParser(allowedPaths: []);
  @override
  Widget build(final BuildContext context) => MaterialApp.router(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: lightThemeData,
        darkTheme: darkThemeData,
        // FIXME: make it dynamic
        themeMode: ThemeMode.light,
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      );
}
