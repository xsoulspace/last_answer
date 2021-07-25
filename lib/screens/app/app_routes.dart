import 'package:flutter/widgets.dart';
import 'package:lastanswer/screens/home/home.dart';

class AppRoutesName {
  static const home = '/';
}

const homeScreen = Home();
final Map<String, WidgetBuilder> allRoutes = {
  AppRoutesName.home: (_) => homeScreen
};
