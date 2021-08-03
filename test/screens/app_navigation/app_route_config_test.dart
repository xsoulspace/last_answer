import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/screens/app_navigator/app_navigator.dart';

void main() {
  group('[AppRouteConfig]', () {
    test('all routes validatating and equal to [AppRoutesName.values]', () {
      final createIdea = AppRouteConfig.createIdea();
      expect(createIdea.isCreateIdea, isTrue);

      final idea = AppRouteConfig.idea(id: '1');
      expect(idea.isIdea, isTrue);

      final note = AppRouteConfig.note(id: '1');
      expect(note.isNote, isTrue);

      final story = AppRouteConfig.story(id: '1');
      expect(story.isStory, isTrue);

      final unknown = AppRouteConfig.unknown();
      expect(unknown.isUnknown, isTrue);

      final settings = AppRouteConfig.settings();
      expect(settings.isSettings, isTrue);

      final home = AppRouteConfig.home();
      expect(home.isHome, isTrue);

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
