import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/home/home.dart';

import '../../util_functions.dart';

void main() {
  group('[idea project screen]', () {
    testWidgets(
      'has center icon',
      (final tester) async {
        const screenWidget = MaterialApp(
          home: IdeaProjectScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: IdeaProjectKeys.ideaCenterPicture);
      },
    );
    testWidgets(
      'has header',
      (final tester) async {
        // TODO(arenukvern): switch locale to english
        const screenWidget = MaterialApp(
          home: IdeaProjectScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();
        expect(find.text("What's your idea?"), findsOneWidget);
      },
    );
    testWidgets('has idea name field', (final tester) async {
      const screenWidget = MaterialApp(
        home: IdeaProjectScreen(),
      );

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      testWidget(keyValue: HomeKeys.ideaNameField);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
