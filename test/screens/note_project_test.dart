import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/home/home.dart';

import '../util_functions.dart';
import 'abstract_setups.dart';

void main() {
  setupAbstractions([setupNoteProjectMockTypes]);
  group('[note project screen]', () {
    final mockNoteProject = MockNoteProject();
    testWidgets(
      'has top app bar and its elements',
      (final tester) async {
        final screenWidget = MaterialApp(
          home: NoteProjectScreen(
            project: mockNoteProject,
          ),
        );

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.text(mockNoteProject.title), findsOneWidget);
      },
    );
    // TODO(arenukvern): test for title onPressed (TextFormField, save on close)
    testWidgets('has rich text field (area)', (final tester) async {
      const screenWidget = MaterialApp(
        home: NoteProjectScreen(),
      );

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      testWidget(keyValue: NoteProjectKeys.noteTextField);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });
  });
}
