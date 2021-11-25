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
        if (questions.isEmpty) {
          await questions.putAll(
            Map.fromEntries(
              _initialQuestions.map((final e) => MapEntry(e.id, e)),
            ),
          );
        }

        settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

        MapState.load(
          ref: ref,
          provider: ideaProjectQuestionsProvider,
          box: questions,
        );

        settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

        final ideaProjectsState = MapState.load(
          ref: ref,
          provider: ideaProjectsProvider,
          box: ideas,
        );

        settings.loadingStatus = AppStateLoadingStatuses.notes;

        final notes = await Hive.openBox<NoteProject>(
          HiveBoxesIds.noteProjectKey,
        );

        final notesProjectsState = MapState.load(
          ref: ref,
          provider: noteProjectsProvider,
          box: notes,
        );

        await Hive.openBox<StoryProject>(
          HiveBoxesIds.storyProjectKey,
        );

        final projectsFolders = await Hive.openBox<ProjectFolder>(
          HiveBoxesIds.projectFolderKey,
        );

        final projectsService = BasicProjectsService(
          ideas: ideaProjectsState.safeState,
          notes: notesProjectsState.safeState,
          // TODO(arenukvern): add stories in v4
          stories: const {},
        );

        ProjectFolder currentFolder;

        if (projectsFolders.isEmpty) {
          currentFolder = await ProjectFolder.create();
        } else {
          MapState.load(
            ref: ref,
            provider: projectsFoldersProvider,
            box: projectsFolders,
          );

          for (final projectsFolder in projectsFolders.values) {
            ProjectFolder.loadProjectsFromService(
              folder: projectsFolder,
              service: projectsService,
            );
          }

          // TODO(arenukvern): add last used folder
          currentFolder = projectsFolders.values.first;
        }

        ref.read(currentFolderProvider.notifier).state = currentFolder;

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
