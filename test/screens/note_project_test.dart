import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/note_project/note_project.dart';

import '../abstract_setups.dart';

void main() {
  setupAbstractions([setupNoteProjectMockTypes]);
  final mockNoteProject = MockNoteProject();

  Widget getScreenWidget() => MaterialApp(
        home: NoteProjectScreen(
          noteId: mockNoteProject.id,
          onBack: () {},
        ),
      );
  group('[note project screen]', () {
    testWidgets(
      'has top app bar and its elements',
      (final tester) async {
        final screenWidget = getScreenWidget();

        await tester.pumpWidget(screenWidget);
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.text(mockNoteProject.title), findsOneWidget);
      },
    );
    // TODO(arenukvern): test for title onPressed (TextFormField, save on close)
    testWidgets('has rich text field (area)', (final tester) async {
      final screenWidget = getScreenWidget();

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      // testWidget(keyValue: NoteProjectScreenKeys.noteTextField);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });
  });
}
