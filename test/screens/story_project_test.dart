import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/story_project/story_project.dart';

import '../abstract_setups.dart';

void main() {
  setupAbstractions([setupNoteProjectMockTypes]);
  final mockStoryProject = MockStoryProject();

  Widget getScreenWidget() => MaterialApp(
        home: StoryProjectScreen(
          projectId: mockStoryProject.id,
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
