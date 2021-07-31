import 'package:flutter/widgets.dart';
import 'package:lastanswer/screens/home/home_screen.dart';

class AppRoutesName {
  static const home = '/';
}

const homeScreen = HomeScreen();
final Map<String, WidgetBuilder> allRoutes = {
  AppRoutesName.home: (final _) => homeScreen
};
