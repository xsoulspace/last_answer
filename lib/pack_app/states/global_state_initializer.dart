part of pack_app;

/// use for data migrations only
// ignore: unused_element
Future<Box<T>> _openAnyway<T>(final String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    await Hive.deleteBoxFromDisk(boxName);
  }

  return Hive.openBox<T>(boxName);
}

class GlobalStateInitializer implements StateInitializer {
  GlobalStateInitializer({
    required final this.settings,
  });
  final SettingsController settings;

  @override
  // ignore: long-method
  Future<void> onLoad({required final BuildContext context}) async {
    /// ********************************************
    /// *      CONTEXT RELATED READINGS START
    /// ********************************************

    final lastEmojiProvider = context.read<LastEmojiProvider>();
    final specialEmojiProvider = context.read<SpecialEmojiProvider>();
    final emojiProvider = context.read<EmojiProvider>();
    final currentFolderProvider = context.read<FolderStateProvider>();
    final notificationController = context.read<NotificationController>();
    final paymentsController = context.read<PaymentsController>();

    /// ********************************************
    /// *      CONTEXT RELATED READINGS END
    /// ********************************************

    /// ********************************************
    /// *      CONTENT LOADING START
    /// ********************************************

    /// Loadindependent controllers
    final loadableControllers = <Loadable>[
      settings,
      paymentsController,
    ];
    await Future.forEach<Loadable>(
      loadableControllers,
      (final loadable) => loadable.onLoad(context: context),
    );

    settings.loadingStatus = AppStateLoadingStatuses.emoji;
    // ignore: use_build_context_synchronously
    final emojis = await EmojiUtil.getList(context);

    emojiProvider.putEntries(emojis.map((final e) => MapEntry(e.emoji, e)));

    // ignore: use_build_context_synchronously
    final specialEmojis = await EmojiUtil.getSpecialList(context);
    specialEmojiProvider
        .putEntries(specialEmojis.map((final e) => MapEntry(e.emoji, e)));

    final lastUsedEmojis = await EmojiUtil().load();
    lastEmojiProvider.putAll(lastUsedEmojis);

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
          initialQuestions.map((final e) => MapEntry(e.id, e)),
        ),
      );
    }

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    MapState.load<IdeaProjectQuestion, IdeaProjectQuestionsProvider>(
      context: context,
      box: questions,
    );

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    final ideaProjectsState = MapState.load<IdeaProject, IdeaProjectsProvider>(
      context: context,
      box: ideas,
    );

    settings.loadingStatus = AppStateLoadingStatuses.notes;

    final notes = await Hive.openBox<NoteProject>(
      HiveBoxesIds.noteProjectKey,
    );

    final notesProjectsState = MapState.load<NoteProject, NoteProjectsProvider>(
      context: context,
      box: notes,
    );

    await Hive.openBox<StoryProject>(
      HiveBoxesIds.storyProjectKey,
    );

    final projectsFolders = await Hive.openBox<ProjectFolder>(
      HiveBoxesIds.projectFolderKey,
    );

    final projectsService = BasicProjectsService(
      ideas: ideaProjectsState.state,
      notes: notesProjectsState.state,
      // TODO(arenukvern): add stories in v4
      stories: const {},
    );

    ProjectFolder currentFolder;

    /// case if project folders is not created
    if (projectsFolders.isEmpty) {
      currentFolder = (await ProjectFolder.create())
        ..addProjects([
          ...ideaProjectsState.state.values,
          ...notesProjectsState.state.values,
        ]);
    } else {
      MapState.load<ProjectFolder, ProjectsFolderProvider>(
        context: context,
        box: projectsFolders,
      );

      for (final projectsFolder in projectsFolders.values) {
        final projects = ProjectFolder.loadProjectsFromService(
          folder: projectsFolder,
          service: projectsService,
        );
        projectsFolder.setExistedProjects(projects);
      }

      // TODO(arenukvern): add last used folder
      currentFolder = projectsFolders.values.first;
    }
    currentFolderProvider.setState(currentFolder);

    /// ********************************************
    /// *      CONTENT LOADING END
    /// ********************************************

    /// ********************************************
    /// *      MIGRATIONS START
    /// ********************************************

    // TODO(arenukvern): keep it in case of future migrations - how to automate it?
    // settings.loadingStatus = AppStateLoadingStatuses.migratingOldData;
    // if (!settings.migrated) {
    //   await settings.setMigrated();
    // }

    await notificationController.onLoad(context: context);

    /// ********************************************
    /// *      MIGRATIONS END
    /// ********************************************
    WidgetsBinding.instance?.addPostFrameCallback((final _) {
      settings.notify();
    });
  }
}
