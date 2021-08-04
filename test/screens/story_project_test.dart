import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/note_project/note_project.dart';

import '../abstract_setups.dart';

void main() {
  setupAbstractions([setupNoteProjectMockTypes]);
  final mockStoryProject = MockStoryProject();

  Widget getScreenWidget() => MaterialApp(
        home: StoryProjectScreen(
          project: mockStoryProject,
        ),
      );
  group('[StoryProjectScreen]', () {
    testWidgets('', (tester) async {
      final screenWidget = getScreenWidget();

      await tester.pumpWidget(screenWidget);
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
