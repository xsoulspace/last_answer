import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/home/home.dart';

import '../util_functions.dart';

void main() {
  group('[home screen]', () {
    testWidgets(
      'has vertical menu and its elements',
      (final tester) async {
        const screenWidget = MaterialApp(
          home: HomeScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: HomeKeys.iconButtonIdea);
        testWidget(keyValue: HomeKeys.iconButtonNote);
        testWidget(keyValue: HomeKeys.iconButtonStory);
      },
    );
    testWidgets(
      'has top app bar and its elements',
      (final tester) async {
        const screenWidget = MaterialApp(
          home: HomeScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Good evening'), findsOneWidget);
        testWidget(keyValue: HomeKeys.iconButtonInfo);
        testWidget(keyValue: HomeKeys.iconButtonSettings);
      },
    );
    testWidgets(
      'has projects list',
      (final tester) async {
        const screenWidget = MaterialApp(
          home: HomeScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: HomeKeys.projectsList);
        expect(find.byType(ListView), findsOneWidget);
      },
    );
  });
}
