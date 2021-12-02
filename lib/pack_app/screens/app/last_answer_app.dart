part of pack_app;

class LastAnswerApp extends StatelessWidget {
  const LastAnswerApp({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return AppStateProvider(
      builder: (final _) => const AppScaffold(),
    );
  }
}
