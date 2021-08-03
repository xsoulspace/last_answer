import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/screens/app_navigator/app_navigator.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({Key? key}) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final _routerDelegate = AppRouterDelegate();
  final _routeInformationParser = AppRouteInformationParser();
  @override
  Widget build(BuildContext context) => MaterialApp.router(
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
