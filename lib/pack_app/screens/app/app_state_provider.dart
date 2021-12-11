part of pack_app;

class AppStateProvider extends StatelessWidget {
  const AppStateProvider({
    required final this.builder,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;
  SettingsController get _settings => GlobalStateNotifiers.settings;
  @override
  Widget build(final BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: createEmojiProvider),
        ChangeNotifierProvider(create: createLastUsedEmojisProvider),
        ChangeNotifierProvider(create: createSpecialEmojisProvider),
        ChangeNotifierProvider(create: createProjectsFoldersProvider),
        ChangeNotifierProvider(create: createCurrentFolderProvider),
        ChangeNotifierProvider(create: createIdeaProjectsProvider),
        ChangeNotifierProvider(create: createIdeaProjectQuestionsProvider),
        ChangeNotifierProvider(create: createNoteProjectsProvider),
        ChangeNotifierProvider(create: createNotificationController),
      ],
      child: Portal(
        child: SettingsStateScope(
          notifier: _settings,
          child: Builder(
            builder: (final context) {
              return StateLoader(
                initializer: GlobalStateInitializer(
                  settings: _settings,
                ),
                loader: const AppLoadingScreen(),
                child: builder(context),
              );
            },
          ),
        ),
      ),
    );
  }
}
