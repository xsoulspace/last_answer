import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_automations/ui_automations.dart';

/// The Automations surface (ADR 0032): the device's declared automations
/// — Services, Schedules, Agents — each with its schedule strip, the
/// execution controls and the one editor sheet. Hosted as a shell view
/// tab (`rail.automations`, the `+` picker, the palette); the shell
/// grammar keeps zero exceptions, so there is no Scaffold here and no
/// route push — the tab is the frame.
///
/// The pane itself ([SupervisorPanel]) carries the title row with the
/// add/refresh verbs, the honest empty/unsupported states and the
/// editor; this surface is its frame plus the scroll every list here
/// needs once the declared set grows.
class AutomationsSurface extends StatelessWidget {
  const AutomationsSurface({super.key});

  @override
  Widget build(final BuildContext context) => const SingleChildScrollView(
    key: ValueKey('automations.surface'),
    padding: EdgeInsets.fromLTRB(16, 14, 16, 24),
    child: SupervisorPanel(key: ValueKey('automations.panel')),
  );
}
