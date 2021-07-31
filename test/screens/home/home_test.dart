import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/home/home_screen.dart';

void main() {
  testWidgets(
    'home page is created',
    (final tester) async {
      const testWidget = MaterialApp(
        home: HomeScreen(),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final buttonMaterial = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Material),
      );

      final materialButton = tester.widget<Material>(buttonMaterial);

      expect(materialButton.color, Colors.blue);
      expect(find.text('Weather today'), findsOneWidget);
      expect(find.byKey(const Key('icon_weather')), findsOneWidget);
    },
  );
  testWidgets('notify when button is pressed', (final tester) async {
    bool pressed = false;
    final testWidget = MaterialApp(
      home: HomeScreen(
        onPressed: () => pressed = true,
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });
}
