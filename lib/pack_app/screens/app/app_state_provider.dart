part of pack_app;

class AppStateProvider extends StatelessWidget {
  const AppStateProvider({
    required final this.builder,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;
  GeneralSettingsController get _settings => GlobalStateNotifiers.settings;

  @override
  Widget build(final BuildContext context) {
    final child = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: createConnectivityNotifier),
        ChangeNotifierProvider(create: createUsersNotifier),

        /// ********************************************
        /// *      API START
        /// ********************************************
        Provider<supabase_lib.SupabaseClient>(
          create: (final context) => GlobalStateNotifiers.supabase,
        ),
        Provider(
          create: createApiProviderBuilder(FoldersApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(ProjectsApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(IdeaProjectAnswersApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(IdeaProjectQuestionApi.new),
        ),
        Provider(
          create: createApiProviderBuilder(UsersApi.new),
        ),

        /// ********************************************
        /// *      API END
        /// ********************************************
        ///
        /// ********************************************
        /// *      IN MEMORY NOTIFIERS START
        /// ********************************************
        /// Keep _settings is global is important as it will not lose all
        /// changes during global rebuild
        ChangeNotifierProvider(create: (final context) => _settings),
        ChangeNotifierProvider(create: createEmojiProvider),
        ChangeNotifierProvider(create: createLastUsedEmojisProvider),
        ChangeNotifierProvider(create: createSpecialEmojisProvider),
        ChangeNotifierProvider(create: createFoldersNotifier),
        ChangeNotifierProvider(create: createCurrentFoldersNotifier),
        ChangeNotifierProvider(create: createIdeaProjectsNotifier),
        ChangeNotifierProvider(create: createIdeaProjectAnswersNotifier),
        ChangeNotifierProvider(create: createIdeaProjectQuestionsProvider),
        ChangeNotifierProvider(create: createNoteProjectsNotifier),
        ChangeNotifierProvider(create: createNotificationController),

        ChangeNotifierProvider<PaymentsControllerI>(
          create: (final context) => createMockPaymentsController(),
        ),

        /// ********************************************
        /// *      IN MEMORY NOTIFIERS END
        /// ********************************************
        ///
        /// ********************************************
        /// *      SERVER NOTIFIERS START
        /// ********************************************
        ///
        /// ********************************************
        /// *      SYNC SERVICES - CLIENT
        /// ********************************************
        Provider(create: ClientFolderSyncService.of),
        Provider(create: ClientIdeaSyncService.of),
        Provider(create: ClientIdeaAnswerSyncService.of),
        Provider(create: ClientIdeaQuestionSyncService.of),
        Provider(create: ClientNoteSyncService.of),

        /// ********************************************
        /// *      SYNC SERVICES - SERVER
        /// ********************************************
        Provider(create: createServerFolderSyncService),
        Provider(create: createServerIdeaSyncService),
        Provider(create: createServerIdeaAnswerSyncService),
        Provider(create: createServerIdeaQuestionSyncService),
        Provider(create: createServerNoteSyncService),

        /// ********************************************
        /// *      UPDATERS
        /// ********************************************
        Provider(create: createFolderUpdater),
        Provider(create: createIdeaUpdater),
        Provider(create: createIdeaAnswerUpdater),
        Provider(create: createIdeaQuestionUpdater),
        Provider(create: createNoteUpdater),

        /// ********************************************
        /// *      SUBSCRIBERS
        /// ********************************************

        ChangeNotifierProvider(create: createFolderSubscriberNotifier),
        ChangeNotifierProvider(create: createProjectsSubscriberNotifier),
        ChangeNotifierProvider(create: createIdeaAnswerSubscriberNotifier),
        ChangeNotifierProvider(create: createIdeaQuestionSubscriberNotifier),

        /// ********************************************
        /// *      WORKER
        /// ********************************************
        ChangeNotifierProvider(create: createServerSyncWorkerNotifier)
      ],
      child: Portal(
        child: _AppStateInitializer(builder: builder),
      ),
    );
    if (isNativeDesktop) {
      return child;
    }

    return Directionality(
      // TODO(arenukvern): replace with default device textDirection
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(color: AppColors.black),
          child,
        ],
      ),
    );
  }
}

class _AppStateInitializer extends HookWidget {
  const _AppStateInitializer({
    required final this.builder,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;

  @override
  Widget build(final BuildContext context) {
    final authState = useAppAuthState(
      supabaseClient: context.read(),
    );

    return Provider(
      create: (final context) => authState,
      child: StateLoader(
        initializer: GlobalStateInitializer(
          settings: context.read(),
          authState: authState,
        ),
        loader: const AppLoadingScreen(),
        child: builder(context),
      ),
    );
  }
}
