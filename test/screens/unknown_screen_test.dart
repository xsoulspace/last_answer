import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/unknown/unknown.dart';

void main() {
  Widget getScreenWidget() => const MaterialApp(home: UnknownScreen());
  group('[UnknownScreen]', () {
    testWidgets('', (tester) async {
      final screenWidget = getScreenWidget();

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      expect(find.text('This project is not exsits.. But!'), findsOneWidget);

      expect(find.text('Create new one what you like:'), findsOneWidget);
    });
  });
}
