part of app_provider;

class AppStoreInitializer extends ConsumerWidget {
  const AppStoreInitializer({
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
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
        final ideas =
            await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);

        await Hive.openBox<IdeaProjectAnswer>(
          HiveBoxesIds.ideaProjectAnswerKey,
        );
        final questions = await Hive.openBox<IdeaProjectQuestion>(
          HiveBoxesIds.ideaProjectQuestionKey,
        );
        if (questions.isEmpty) {
          await questions.putAll(
            Map.fromEntries(
              _initialQuestions.map((final e) => MapEntry(e.id, e)),
            ),
          );
        }

        ref.read(ideaProjectQuestionsProvider).state = ref
            .read(ideaProjectQuestionsProvider)
            .state
          ..addAll(questions.values);

        ref.read(ideaProjectsProvider).state = ref
            .read(ideaProjectsProvider)
            .state
          ..addEntries(ideas.values.map((final e) => MapEntry(e.id, e)));

        final notes =
            await Hive.openBox<NoteProject>(HiveBoxesIds.noteProjectKey);

        ref.read(noteProjectsProvider).state = ref
            .read(noteProjectsProvider)
            .state
          ..addEntries(notes.values.map((final e) => MapEntry(e.id, e)));

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
