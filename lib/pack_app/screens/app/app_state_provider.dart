part of pack_app;

class AppStateProvider extends StatelessWidget {
  const AppStateProvider({
    required this.builder,
    super.key,
  });
  final WidgetBuilder builder;
  GeneralSettingsController get _settings => GlobalStateNotifiers.settings;
  @override
  Widget build(final BuildContext context) {
    final child = MultiProvider(
      providers: [
        /// Keep _settings is global is important as it will not lose all
        /// changes during global rebuild
        ChangeNotifierProvider(create: (final _) => _settings),
        ChangeNotifierProvider(create: createEmojiProvider),
        ChangeNotifierProvider(create: createLastUsedEmojisProvider),
        ChangeNotifierProvider(create: createSpecialEmojisProvider),
        ChangeNotifierProvider(create: createProjectsFoldersProvider),
        ChangeNotifierProvider(create: createCurrentFolderProvider),
        ChangeNotifierProvider(create: createIdeaProjectsState),
        ChangeNotifierProvider(create: createIdeaProjectQuestionsState),
        ChangeNotifierProvider(create: createNoteProjectsState),
        ChangeNotifierProvider(create: createNotificationController),
        ChangeNotifierProvider(create: createPaymentsController),
      ],
      child: Portal(
        child: Builder(
          builder: (final context) => StateLoader(
            initializer: GlobalStateInitializer(
              settings: _settings,
              context: context,
            ),
            loader: const AppLoadingScreen(),
            child: builder(context),
          ),
        ),
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
