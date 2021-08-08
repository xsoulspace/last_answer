import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/app_navigator/app_navigator.dart';

void main() {
  group('[AppRouteConfig]', () {
    test('all routes validatating and equal to [AppRoutesName.values]', () {
      final createIdea = AppRouteConfig.createIdea();
      expect(createIdea.isCreateIdeaPage, isTrue);

      final idea = AppRouteConfig.idea(id: '1');
      expect(idea.isIdeaPage, isTrue);

      final note = AppRouteConfig.note(id: '1');
      expect(note.isNotePage, isTrue);

      final story = AppRouteConfig.story(id: '1');
      expect(story.isStoryPage, isTrue);

      final unknown = AppRouteConfig.unknown();
      expect(unknown.isUnknownPage, isTrue);

      final settings = AppRouteConfig.settings();
      expect(settings.isSettingsPage, isTrue);

      final home = AppRouteConfig.home();
      expect(home.isHomePage, isTrue);

      /// Validate routes consistency
      final allRoutesInstances = [
        createIdea,
        idea,
        note,
        story,
        unknown,
        settings,
        home,
      ];
      expect(allRoutesInstances.length, equals(AppRoutesName.values.length));
    });
  });
}
