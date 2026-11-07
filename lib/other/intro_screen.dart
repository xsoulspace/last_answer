import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/onboarding/first_run_screen.dart';

/// The `/intro` route body: the first-run flow ("meet your first
/// actor"). The boot routing branch in `GlobalStatesInitializer` sends a
/// fresh user here INSTEAD of the empty shell — everything starts from
/// an actor and a conversation (product law, plan v5). Completion (or
/// the calm skip) persists `hasCompletedOnboarding` and routes home, so
/// the second launch never shows this again.
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(final BuildContext context) => const FirstRunScreen();
}
