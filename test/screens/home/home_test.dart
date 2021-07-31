import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/home/home_screen.dart';

void main() {
  group('[home screen] widgets context', () {
    testWidgets(
      'elements of vertical menu',
      (final tester) async {
        const screenWidget = MaterialApp(
          home: HomeScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.wb_incandescent_outlined), findsOneWidget);
        expect(find.text('Weather today'), findsOneWidget);
        expect(find.byKey(const Key('icon_weather')), findsOneWidget);
      },
    );
  });
}
