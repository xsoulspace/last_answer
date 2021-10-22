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
    if (settings.appInitialStateLoaded & !settings.appInitialStateIsLoading) {
      return child;
    }
    final brightness =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .platformBrightness;
    return FutureBuilder<bool>(
      future: () async {
        if (settings.appInitialStateLoaded) {
          return !settings.appInitialStateIsLoading;
        }
        settings
          ..appInitialStateLoaded = true
          ..appInitialStateIsLoading = true;
        await SettingsStateScope.of(context).load();

        await Hive.openBox<IdeaProjectAnswer>(
          HiveBoxesIds.ideaProjectAnswerKey,
        );

        final ideas =
            await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);

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

        ref.read(ideaProjectQuestionsProvider.notifier).putAll(
              Map.fromEntries(
                questions.values.map((final e) => MapEntry(e.id, e)),
              ),
            );

        ref.read(ideaProjectsProvider.notifier).putAll(
              Map.fromEntries(
                ideas.values.map((final e) => MapEntry(e.id, e)),
              ),
            );

        final notes =
            await Hive.openBox<NoteProject>(HiveBoxesIds.noteProjectKey);

        ref.read(noteProjectsProvider.notifier).putAll(
              Map.fromEntries(
                notes.values.map((final e) => MapEntry(e.id, e)),
              ),
            );

        await Hive.openBox<StoryProject>(HiveBoxesIds.storyProjectKey);

        /// ***************** MIGRATION START *******************

        // TODO(arenukvern): remove old stores after all devices migration
        try {
          if (await Hive.boxExists(HiveBoxesIds.darkModeKey)) {
            await Hive.deleteBoxFromDisk(HiveBoxesIds.darkModeKey);
          }
          if (await Hive.boxExists(HiveBoxesIds.projectsKey) &&
              await Hive.boxExists(HiveBoxesIds.answersKey)) {
            await Hive.openBox<Answer>(HiveBoxesIds.answersKey);
            final projects =
                await Hive.openBox<Project>(HiveBoxesIds.projectsKey);

            for (final project in projects.values) {
              await project.saveAsIdeaProject(ref);
            }
            await Hive.deleteBoxFromDisk(HiveBoxesIds.answersKey);
            await Hive.deleteBoxFromDisk(HiveBoxesIds.projectsKey);
          }
        } catch (e) {
          print('error: $e');
        }

        /// ***************** MIGRATION END *******************
        settings.appInitialStateIsLoading = false;
        WidgetsBinding.instance?.addPostFrameCallback((final _) {
          settings.notify();
        });
        return true;
      }(),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == false) {
          return Container(
            color: brightness == Brightness.dark
                ? AppColors.black
                : AppColors.white,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary2),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
