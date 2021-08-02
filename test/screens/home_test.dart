import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/home/home.dart';

import '../util_functions.dart';

void main() {
  // TODO(arenukvern): siwtch to english
  Widget getScreenWidget() => const MaterialApp(
        home: HomeScreen(),
      );
  group('[home screen]', () {
    testWidgets(
      'has top app bar and its elements',
      (final tester) async {
        final screenWidget = getScreenWidget();

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Good evening'), findsOneWidget);
        testWidget(keyValue: HomeScreenKeys.iconButtonInfo);
        testWidget(keyValue: HomeScreenKeys.iconButtonSettings);
      },
    );
    testWidgets(
      'has vertical menu and its elements',
      (final tester) async {
        final screenWidget = getScreenWidget();

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: HomeScreenKeys.iconButtonIdea);
        testWidget(keyValue: HomeScreenKeys.iconButtonNote);
        testWidget(keyValue: HomeScreenKeys.iconButtonStory);
      },
    );

    testWidgets(
      'has projects list',
      (final tester) async {
        final screenWidget = getScreenWidget();

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: HomeScreenKeys.projectsList);
        expect(find.byType(ListView), findsOneWidget);
      },
    );
  });
}
