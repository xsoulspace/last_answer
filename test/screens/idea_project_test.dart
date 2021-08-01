import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/home/home.dart';
import 'package:mocktail/mocktail.dart';

import '../util_functions.dart';
import 'abstract_setups.dart';

void main() {
  setupAbstractions([setupIdeaProjectMockTypes]);
  group('[idea project screen]', () {
    final mockIdeaProject = MockIdeaProject();
    testWidgets(
      'has top app bar and its elements',
      (final tester) async {
        final screenWidget = MaterialApp(
          home: IdeaProjectScreen(
            project: mockIdeaProject,
          ),
        );

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
        const screenWidget = MaterialApp(
          home: IdeaProjectScreen(),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();
        testWidget(keyValue: IdeaProjectKeys.answersList);
        expect(find.byType(ListView), findsOneWidget);
      },
    );
    testWidgets('has question bubbles', (final tester) async {
      const screenWidget = MaterialApp(
        home: IdeaProjectScreen(),
      );

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      testWidget(keyValue: IdeaProjectKeys.questionBubbles);
    });
    testWidgets('has share button', (final tester) async {
      const screenWidget = MaterialApp(
        home: IdeaProjectScreen(),
      );

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      testWidget(keyValue: IdeaProjectKeys.iconButtonShare);
    });
    testWidgets('has answer field', (final tester) async {
      const screenWidget = MaterialApp(
        home: IdeaProjectScreen(),
      );

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      testWidget(keyValue: IdeaProjectKeys.answerField);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
    // TODO(arenukvern): test save answer
  });
}
