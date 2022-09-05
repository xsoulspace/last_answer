import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/library/widgets/widgets.dart';

class NavigatorValueKeys {
  NavigatorValueKeys._();
  static const home = ValueKey<String>('home');
  static const settings = ValueKey<String>('settings');
  static const signIn = ValueKey<String>('sign-in');
  static const info = ValueKey<String>('info');
  static const notes = ValueKey<String>('notes');
  static const notesNote = ValueKey<String>('notes/note');
  static const createIdea = ValueKey<String>('createIdea');
  static const ideas = ValueKey<String>('ideas');
  static const ideasIdea = ValueKey<String>('ideas/idea');
  static const ideasIdeaAnswer = ValueKey<String>('ideas/idea/answer');
  static final largeScreenHomeNavigator = GlobalKey();
}

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class AppNavigator extends StatefulWidget {
  const AppNavigator({
    required this.navigatorKey,
    required this.routeState,
    final Key? key,
  }) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  final RouteState routeState;
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);

    return ResponsiveNavigator(
      navigatorKey: widget.navigatorKey,
      onLargeScreen: layoutBuilder.getLargeScreenPages,
      onSmallScreen: layoutBuilder.getSmallScreenPages,
      onPopPage: popper.onPopPage,
    );
  }
}
