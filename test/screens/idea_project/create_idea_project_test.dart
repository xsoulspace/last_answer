import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/idea_project/idea_project.dart';

import '../../util_functions.dart';

void main() {
  // TODO(arenukvern): switch locale to english
  Widget getScreenWidget() => const MaterialApp(
        home: CreateIdeaProjectScreen(),
      );

  group('[create idea project screen]', () {
    testWidgets(
      'has center icon',
      (final tester) async {
        final screenWidget = getScreenWidget();

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        testWidget(keyValue: CreateIdeaProjectScreenKeys.ideaCenterPicture);
      },
    );
    testWidgets(
      'has header',
      (final tester) async {
        final screenWidget = getScreenWidget();
        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();
        expect(find.text("What's your idea?"), findsOneWidget);
      },
    );
    testWidgets('has idea name field', (final tester) async {
      final screenWidget = getScreenWidget();

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      testWidget(keyValue: CreateIdeaProjectScreenKeys.ideaNameField);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
    // TODO(arenukvern): test start new idea
  });
}
