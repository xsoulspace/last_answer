import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/common_imports.dart';

/// The "Agents & Models" settings tab: the user-friendly wrapper over the
/// one agent config document — register ACP agent servers, provider keys
/// and models, chat defaults (Zed-parity config, UI-first).
class AgentSettingsView extends StatelessWidget {
  const AgentSettingsView({this.padding, super.key});

  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    if (!context.read<AgentConfigStore>().isLoaded) {
      unawaited(context.read<AgentConfigStore>().load());
    }
    return ListenableBuilder(
      listenable: context.read<AgentConfigStore>(),
      builder: (final context, _) => const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: AgentConfigSettingsPane(closeOnSave: false),
        ),
      ),
    );
  }
}
