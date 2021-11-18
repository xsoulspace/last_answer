part of app_provider;

/// use for data migrations only
Future<Box<T>> _openAnyway<T>(final String boxName) async {
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
        // ignore: use_build_context_synchronously
        final emojis = await EmojiUtil.getList(context);

        ref
            .read(emojisProvider.notifier)
            .putEntries(emojis.map((final e) => MapEntry(e.emoji, e)));

        // ignore: use_build_context_synchronously
        final specialEmojis = await EmojiUtil.getSpecialList(context);
        ref
            .read(specialEmojisProvider.notifier)
            .putEntries(specialEmojis.map((final e) => MapEntry(e.emoji, e)));

        final lastUsedEmojis = await EmojiUtil().load();
        ref.read(lastUsedEmojisProvider.notifier).putAll(lastUsedEmojis);

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

        // TODO(arenukvern): comment when all devices will be updated
        /// to new version ^3.6
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

        // TODO(arenukvern): in case of future migrations
        // settings.loadingStatus = AppStateLoadingStatuses.migratingOldData;
        // if (!settings.migrated) {
        //   await settings.setMigrated();
        // }

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
