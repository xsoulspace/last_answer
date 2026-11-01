
import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_page.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/actors_panel.dart';
import 'package:lastanswer/settings/features/mesh_tasks_settings_page.dart';

/// The "Agents & Models" settings tab (ADR 0023): actor identities
/// (create/watch/remove), the one agent config document (ACP agent
/// servers, provider keys and models, chat defaults), and observability
/// (world inspector, mesh tasks) that used to live under every doc.
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
      builder: (final context, _) => SingleChildScrollView(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ActorsPanel(),
            ),
            const Divider(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AgentConfigSettingsPane(closeOnSave: false),
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    key: const ValueKey('settings.world_inspector'),
                    onPressed: () => unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          fullscreenDialog: true,
                          builder: (final routeContext) =>
                              const WorldInspectorFullScreenPage(),
                        ),
                      ),
                    ),
                    child: Text(context.l10n.settingsWorldInspector),
                  ),
                  OutlinedButton(
                    key: const ValueKey('settings.mesh_tasks'),
                    onPressed: () => unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (final routeContext) =>
                              const MeshTasksSettingsPage(),
                        ),
                      ),
                    ),
                    child: Text(context.l10n.settingsMeshTasks),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
