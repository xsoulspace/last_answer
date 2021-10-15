import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/idea_project/idea_project.dart';

import '../../abstract_setups.dart';

void main() {
  setupAbstractions([setupIdeaProjectMockTypes]);
  final mockIdeaProject = MockIdeaProject();
  Widget getScreenWidget() => MaterialApp(
        home: IdeaProjectScreen(
          projectId: mockIdeaProject.id,
        ),
      );
  group('[idea project screen]', () {
    testWidgets(
      'has top app bar and its elements',
      (final tester) async {
        final screenWidget = getScreenWidget();

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.text(mockIdeaProject.title), findsOneWidget);
      },
    );
    // TODO(arenukvern): test for title onPressed (TextFormField, save on close)
    testWidgets(
      'has list of answers',
      (final tester) async {
        final screenWidget = getScreenWidget();

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();
        // testWidget(keyValue: IdeaProjectScreenKeys.answersList);
        expect(find.byType(ListView), findsOneWidget);
      },
    );
    testWidgets('has question bubbles', (final tester) async {
      final screenWidget = getScreenWidget();

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      // testWidget(keyValue: IdeaProjectScreenKeys.questionBubbles);
    });
    testWidgets('has share button', (final tester) async {
      final screenWidget = getScreenWidget();

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      // testWidget(keyValue: IdeaProjectScreenKeys.iconButtonShare);
    });
    testWidgets('has answer field', (final tester) async {
      final screenWidget = getScreenWidget();

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      // testWidget(keyValue: IdeaProjectScreenKeys.answerField);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
    // TODO(arenukvern): test save answer
  });
}
