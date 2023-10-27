part of '../../pack_app.dart';

class LastAnswerApp extends StatelessWidget {
  const LastAnswerApp({super.key});

  @override
  Widget build(final BuildContext context) => AppStateProvider(
        builder: (final _) => const AppScaffold(),
      );
}
