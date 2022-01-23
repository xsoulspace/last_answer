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
        ChangeNotifierProvider(create: createGeneralSettingsController),
      ],
      child: Portal(
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
