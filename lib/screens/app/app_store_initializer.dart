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
        try {
          print('start');
          if (settings.appInitialStateLoaded) {
            return !settings.appInitialStateIsLoading;
          }
          print('settings to true');
          settings
            ..appInitialStateLoaded = true
            ..appInitialStateIsLoading = true;
          await SettingsStateScope.of(context).load();
          print('settings loaded');
          await Hive.openBox<IdeaProjectAnswer>(
            HiveBoxesIds.ideaProjectAnswerKey,
          );
          print('ideaProjectAnswerKey loaded');
          try {} catch (e) {}

          final ideas =
              await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);
          print('ideas loaded');

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
          print('questions loaded');

          ref.read(ideaProjectsProvider.notifier).putAll(
                Map.fromEntries(
                  ideas.values.map((final e) => MapEntry(e.id, e)),
                ),
              );
          print('ideaProjectsProvider loaded');

          final notes =
              await Hive.openBox<NoteProject>(HiveBoxesIds.noteProjectKey);
          print('notes loaded');

          ref.read(noteProjectsProvider.notifier).putAll(
                Map.fromEntries(
                  notes.values.map((final e) => MapEntry(e.id, e)),
                ),
              );
          print('noteProjectsProvider loaded');

          await Hive.openBox<StoryProject>(HiveBoxesIds.storyProjectKey);
          print('StoryProject loaded');

          /// ***************** MIGRATION START *******************

          // TODO(arenukvern): remove old stores after all devices migration
          print('migration started');
          print('darkModeKey started');
          if (await Hive.boxExists(HiveBoxesIds.darkModeKey)) {
            await Hive.deleteBoxFromDisk(HiveBoxesIds.darkModeKey);
          }
          print('darkModeKey ended');
          print('answers migration started');
          if (await Hive.boxExists(HiveBoxesIds.projectsKey) &&
              await Hive.boxExists(HiveBoxesIds.answersKey)) {
            await Hive.openBox<Answer>(HiveBoxesIds.answersKey);
            final projects =
                await Hive.openBox<Project>(HiveBoxesIds.projectsKey);
            print('projects started');

            for (final project in projects.values) {
              print('project $project');
              await project.saveAsIdeaProject(ref);
            }
            await Hive.deleteBoxFromDisk(HiveBoxesIds.answersKey);
            await Hive.deleteBoxFromDisk(HiveBoxesIds.projectsKey);
          }
          print('projects completed and removed');
        } catch (e) {
          print('error: $e');
        }

        /// ***************** MIGRATION END *******************
        settings.appInitialStateIsLoading = false;
        print('loaded. preparing to reload');
        WidgetsBinding.instance?.addPostFrameCallback((final _) {
          print('notifying to reload');
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
