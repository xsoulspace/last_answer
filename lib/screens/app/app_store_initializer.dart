part of app_provider;

enum AppStateLoadingStatuses {
  settings,
  emoji,
  ideas,
  questionsForAnswers,
  answersForIdeas,
  notes,
  migratingOldData,
}

Future<Box<T>> openAnyway<T>(final String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    await Hive.deleteBoxFromDisk(boxName);
  }
  return Hive.openBox<T>(boxName);
}

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

        final settingsState = SettingsStateScope.of(context);
        await settingsState.load();

        settingsState.loadingStatus = AppStateLoadingStatuses.emoji;
        final emojis = await EmojiUtil.getList(context);

        ref
            .read(emojisProvider.notifier)
            .putEntries(emojis.map((final e) => MapEntry(e.keywords, e)));

        settings.loadingStatus = AppStateLoadingStatuses.ideas;

        await openAnyway<IdeaProjectAnswer>(HiveBoxesIds.ideaProjectAnswerKey);

        final ideas =
            await openAnyway<IdeaProject>(HiveBoxesIds.ideaProjectKey);
        settings.loadingStatus = AppStateLoadingStatuses.questionsForAnswers;

        final questions = await openAnyway<IdeaProjectQuestion>(
          HiveBoxesIds.ideaProjectQuestionKey,
        );
        if (questions.isEmpty) {
          await questions.putAll(
            Map.fromEntries(
              _initialQuestions.map((final e) => MapEntry(e.id, e)),
            ),
          );
        }
        settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

        ref.read(ideaProjectQuestionsProvider.notifier).putAll(
              Map.fromEntries(
                questions.values.map((final e) => MapEntry(e.id, e)),
              ),
            );
        settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

        ref.read(ideaProjectsProvider.notifier).putAll(
              Map.fromEntries(
                ideas.values.map((final e) => MapEntry(e.id, e)),
              ),
            );
        settings.loadingStatus = AppStateLoadingStatuses.notes;

        final notes = await openAnyway<NoteProject>(
          HiveBoxesIds.noteProjectKey,
        );

        ref.read(noteProjectsProvider.notifier).putAll(
              Map.fromEntries(
                notes.values.map((final e) => MapEntry(e.id, e)),
              ),
            );
        await openAnyway<StoryProject>(
          HiveBoxesIds.storyProjectKey,
        );

        settings.loadingStatus = AppStateLoadingStatuses.migratingOldData;

        /// ***************** MIGRATION START *******************
        try {
          // TODO(arenukvern): remove old stores after all devices migration
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
          await Hive.deleteBoxFromDisk(HiveBoxesIds.answersKey);
          await Hive.deleteBoxFromDisk(HiveBoxesIds.projectsKey);
          log('migration error: $e');
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
            child: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary2),
                    ),
                    Text(settings.loadingStatus.toString()),
                  ],
                ),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
