part of app_provider;

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

        await Hive.openBox<IdeaProjectAnswer>(
          HiveBoxesIds.ideaProjectAnswerKey,
        );

        final ideas =
            await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);
        settings.loadingStatus = AppStateLoadingStatuses.questionsForAnswers;

        final questions = await Hive.openBox<IdeaProjectQuestion>(
          HiveBoxesIds.ideaProjectQuestionKey,
        );
        // TODO(arenukvern): uncomment when all devices will be updated
        /// to new version ^3.6

        // if (questions.isEmpty) {
        await questions.putAll(
          Map.fromEntries(
            _initialQuestions.map((final e) => MapEntry(e.id, e)),
          ),
        );
        // }
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

        final notes = await Hive.openBox<NoteProject>(
          HiveBoxesIds.noteProjectKey,
        );

        ref.read(noteProjectsProvider.notifier).putAll(
              Map.fromEntries(
                notes.values.map((final e) => MapEntry(e.id, e)),
              ),
            );
        await Hive.openBox<StoryProject>(
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
          // ignore: avoid_catches_without_on_clauses
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
            color: AppColors.black,
            child: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary2),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      appLoadingStatusesTitles[settings.loadingStatus]
                              ?.getByLanguage(intl.Intl.systemLocale) ??
                          '',
                    ),
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
