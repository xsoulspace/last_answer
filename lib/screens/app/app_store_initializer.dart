import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/settings/settings.dart';

class AppStoreInitializer extends StatelessWidget {
  const AppStoreInitializer({
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    final settings = SettingsStateScope.of(context);
    if (settings.appInitialStateLoaded) return child;
    return FutureBuilder<bool>(
      future: () async {
        if (settings.appInitialStateLoaded) return true;
        settings.appInitialStateLoaded = true;
        await SettingsStateScope.of(context).load();
        // TODO(arenukvern): make migration logic
        // TODO(arenukvern): remove old stores after migration
        await Hive.openBox<bool>(HiveBoxesIds.darkModeKey);
        await Hive.openBox<Project>(HiveBoxesIds.projectsKey);
        await Hive.openBox<Answer>(HiveBoxesIds.answersKey);
        // await Hive.deleteBoxFromDisk(HiveBoxesIds.darkModeKey);
        // await Hive.deleteBoxFromDisk(HiveBoxes.projects);
        // await Hive.deleteBoxFromDisk(HiveBoxes.answers);

        await Hive.openBox<IdeaProjectAnswer>(
          HiveBoxesIds.ideaProjectAnswerKey,
        );
        await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);
        await Hive.openBox<IdeaProjectQuestion>(
          HiveBoxesIds.ideaProjectsQuestionKey,
        );
        await Hive.openBox<NoteProject>(HiveBoxesIds.noteProjectKey);
        await Hive.openBox<StoryProject>(HiveBoxesIds.storyProjectKey);
        return true;
      }(),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // TODO(arenukvern): replace with loader
          return Container();
        }
        return child;
      },
    );
  }
}
