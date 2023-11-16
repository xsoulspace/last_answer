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

class GlobalStateInitializerDto {
  GlobalStateInitializerDto({
    required this.context,
  })  : emojiRepository = context.read(),
        lastUsedEmojiRepository = context.read(),
        lastEmojiProvider = context.read(),
        specialEmojiProvider = context.read(),
        emojiProvider = context.read(),
        currentFolderProvider = context.read(),
        notificationController = context.read(),
        paymentsController = context.read(),
        assetBundle = DefaultAssetBundle.of(context);
  final BuildContext context;
  final EmojiRepository emojiRepository;
  final LastUsedEmojiRepository lastUsedEmojiRepository;
  final AssetBundle assetBundle;
  final LastEmojiState lastEmojiProvider;
  final SpecialEmojiState specialEmojiProvider;
  final EmojiState emojiProvider;
  final FolderStateNotifier currentFolderProvider;
  final NotificationController notificationController;
  final PaymentsController paymentsController;
}

class GlobalStateInitializer implements StateInitializer {
  GlobalStateInitializer({
    required this.dto,
    required this.settings,
  });
  final GlobalStateInitializerDto dto;
  final GeneralSettingsController settings;

  @override
  Future<void> onLoad() async {
    /// ********************************************
    /// *      CONTENT LOADING START
    /// ********************************************

    /// Loadindependent controllers
    final loadableControllers = <Loadable>[
      settings,
      dto.paymentsController,
    ];
    await Future.forEach<Loadable>(
      loadableControllers,
      (final loadable) => loadable.onLoad(),
    );

    settings.loadingStatus = AppStateLoadingStatuses.emoji;
    final emojis = await dto.emojiRepository.getAllEmoji(dto.assetBundle);

    dto.emojiProvider
        .loadIterable(values: emojis, toKey: (final p0) => p0.emoji);

    final specialEmojis =
        await dto.emojiRepository.getSpecialEmoji(dto.assetBundle);
    dto.specialEmojiProvider.loadIterable(
      values: specialEmojis,
      toKey: (final p0) => p0.emoji,
    );

    final lastUsedEmojis = dto.lastUsedEmojiRepository.getAll();
    dto.lastEmojiProvider.putAll(lastUsedEmojis);
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

    // ignore: use_build_context_synchronously
    MapState.load<IdeaProjectQuestion, IdeaProjectQuestionsState>(
      context: dto.context,
      box: questions,
      toKey: (final p0) => p0.id,
    );

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    // ignore: use_build_context_synchronously
    final ideaProjectsState = MapState.load<IdeaProject, IdeaProjectsState>(
      context: dto.context,
      box: ideas,
      toKey: (final p0) => p0.id,
    );

    settings.loadingStatus = AppStateLoadingStatuses.notes;

    final notes = await Hive.openBox<NoteProject>(
      HiveBoxesIds.noteProjectKey,
    );

    // ignore: use_build_context_synchronously
    final notesProjectsState = MapState.load<NoteProject, NoteProjectsState>(
      context: dto.context,
      box: notes,
      toKey: (final p0) => p0.id,
    );

    final projectsFolders = await Hive.openBox<ProjectFolder>(
      HiveBoxesIds.projectFolderKey,
    );

    ProjectFolder currentFolder;

    /// case if project folders is not created
    if (projectsFolders.isEmpty) {
      currentFolder = (await ProjectFolder.create())
        ..addProjects([
          ...ideaProjectsState.values,
          ...notesProjectsState.values,
        ]);
    } else {
      // ignore: use_build_context_synchronously
      MapState.load<ProjectFolder, FolderState>(
        context: dto.context,
        box: projectsFolders,
        toKey: (final p0) => p0.id,
      );

      for (final projectsFolder in projectsFolders.values) {
        final projects = ProjectFolder.loadProjectsFromService(
          folder: projectsFolder,
          ideas: ideaProjectsState,
          notes: notesProjectsState,
        );
        projectsFolder.setExistedProjects(projects);
      }

      // TODO(arenukvern): add last used folder
      currentFolder = projectsFolders.values.first;
    }
    dto.currentFolderProvider.setState(currentFolder);

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
    settings.loadingStatus = AppStateLoadingStatuses.settings;

    await dto.notificationController.onLoad();

    /// ********************************************
    /// *      MIGRATIONS END
    /// ********************************************
    // WidgetsBinding.instance.addPostFrameCallback((final _) {
    //   settings.notify();
    // });
  }
}
