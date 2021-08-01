import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/home/home.dart';
import 'package:mocktail/mocktail.dart';

import '../util_functions.dart';

void main() {
  group('[idea project create screen]', () {
    testWidgets(
      'has center icon',
      (final tester) async {
        const screenWidget = MaterialApp(
          home: IdeaProjectCreateScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: IdeaProjectCreateKeys.ideaCenterPicture);
      },
    );
    testWidgets(
      'has header',
      (final tester) async {
        // TODO(arenukvern): switch locale to english
        const screenWidget = MaterialApp(
          home: IdeaProjectCreateScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();
        expect(find.text("What's your idea?"), findsOneWidget);
      },
    );
    testWidgets('has idea name field', (final tester) async {
      const screenWidget = MaterialApp(
        home: IdeaProjectCreateScreen(),
      );

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      testWidget(keyValue: IdeaProjectCreateKeys.ideaNameField);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
    // TODO(arenukvern): test start new idea
  });
}
