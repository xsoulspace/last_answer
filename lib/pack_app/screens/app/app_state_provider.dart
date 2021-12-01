part of pack_app;

class AppStateProvider extends StatelessWidget {
  const AppStateProvider({
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  SettingsController get _settings => GlobalStateNotifiers.settings;
  @override
  Widget build(final BuildContext context) {
    return Portal(
      child: SettingsStateScope(
        notifier: _settings,
        child: StateLoader(
          initializer: GlobalStateInitializer(
            context: context,
            settings: _settings,
          ),
          loader: const AppLoadingScreen(),
          child: child,
        ),
      ),
    );
  }
}
