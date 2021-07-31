import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/home/home_screen.dart';

void testWidget({required final String keyValue}) {
  final Finder widgetFinder = find.byKey(Key(keyValue));
  expect(widgetFinder, findsOneWidget);
}

void main() {
  group('[home screen]', () {
    testWidgets(
      'has elements of vertical menu',
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
      'has elements of top app bar',
      (final tester) async {
        const screenWidget = MaterialApp(
          home: HomeScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: HomeKeys.iconButtonInfo);
        testWidget(keyValue: HomeKeys.iconButtonSettings);
        expect(find.text('Good evening'), findsOneWidget);
      },
    );
  });
}
