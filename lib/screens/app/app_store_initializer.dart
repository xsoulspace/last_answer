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

class AppStoreInitializer extends StatelessWidget {
  const AppStoreInitializer({
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final settings = SettingsStateScope.of(context);
    if (settings.appInitialStateLoaded & !settings.appInitialStateIsLoading) {
      return child;
    }
    return FutureBuilder<bool>(
      future: initStores(context: context, settings: settings),
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

  Future<bool> initStores({
    required final SettingsController settings,
    required final BuildContext context,
  }) async {
    if (settings.appInitialStateLoaded) {
      return !settings.appInitialStateIsLoading;
    }
    settings
      ..appInitialStateLoaded = true
      ..appInitialStateIsLoading = true;

    await settings.load();

    settings.loadingStatus = AppStateLoadingStatuses.emoji;
    // ignore: use_build_context_synchronously
    final emojis = await EmojiUtil.getList(context);

    emojisProvider.state
        .putEntries(emojis.map((final e) => MapEntry(e.emoji, e)));

    // ignore: use_build_context_synchronously
    final specialEmojis = await EmojiUtil.getSpecialList(context);
    specialEmojisProvider.state
        .putEntries(specialEmojis.map((final e) => MapEntry(e.emoji, e)));

    final lastUsedEmojis = await EmojiUtil().load();
    lastUsedEmojisProvider.state.putAll(lastUsedEmojis);

    settings.loadingStatus = AppStateLoadingStatuses.ideas;

    await Hive.openBox<IdeaProjectAnswer>(
      HiveBoxesIds.ideaProjectAnswerKey,
    );

    final ideas = await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);

    settings.loadingStatus = AppStateLoadingStatuses.questionsForAnswers;

    final questions = await Hive.openBox<IdeaProjectQuestion>(
      HiveBoxesIds.ideaProjectQuestionKey,
    );

    // TODO(arenukvern): comment if questions changed
    if (questions.isEmpty) {
      await questions.putAll(
        Map.fromEntries(
          _initialQuestions.map((final e) => MapEntry(e.id, e)),
        ),
      );
    }

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    MapState.load(
      provider: ideaProjectQuestionsProvider,
      box: questions,
    );

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    final ideaProjectsState = MapState.load(
      provider: ideaProjectsProvider,
      box: ideas,
    );

    settings.loadingStatus = AppStateLoadingStatuses.notes;

    final notes = await Hive.openBox<NoteProject>(
      HiveBoxesIds.noteProjectKey,
    );

    final notesProjectsState = MapState.load(
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

    /// case if project folders is not created
    if (projectsFolders.isEmpty) {
      currentFolder = (await ProjectFolder.create())
        ..addProjects([
          ...ideaProjectsState.safeState.values,
          ...notesProjectsState.safeState.values,
        ]);
    } else {
      MapState.load(
        provider: projectsFoldersProvider,
        box: projectsFolders,
      );

      for (final projectsFolder in projectsFolders.values) {
        final projects = ProjectFolder.loadProjectsFromService(
          folder: projectsFolder,
          service: projectsService,
        );
        projectsFolder.setExistedProjectsList(projects);
      }

      // TODO(arenukvern): add last used folder
      currentFolder = projectsFolders.values.first;
    }
    currentFolderProvider.state.state = currentFolder;

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
  }
}
