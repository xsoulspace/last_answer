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
        /// Keep _settings is global is important as it will not lose all
        /// changes during global rebuild
        ChangeNotifierProvider(create: (final context) => _settings),
        Provider<supabase_lib.SupabaseClient>(
          create: (final context) => GlobalStateNotifiers.supabase,
        ),
        ChangeNotifierProvider(create: createEmojiProvider),
        ChangeNotifierProvider(create: createLastUsedEmojisProvider),
        ChangeNotifierProvider(create: createSpecialEmojisProvider),
        ChangeNotifierProvider(create: createProjectsFoldersProvider),
        ChangeNotifierProvider(create: createCurrentFolderProvider),
        ChangeNotifierProvider(create: createIdeaProjectsProvider),
        ChangeNotifierProvider(create: createIdeaProjectQuestionsProvider),
        ChangeNotifierProvider(create: createNoteProjectsProvider),
        ChangeNotifierProvider(create: createNotificationController),
        ChangeNotifierProvider(create: createPaymentsController),
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
