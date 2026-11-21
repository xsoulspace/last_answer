/// Provider, then model. One control for every brain the actor can name,
/// including provider `acp`.
library;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_agents/acp/acp_bridge_registry.dart';
import 'package:lastanswer/data_agents/acp/acp_provider.dart';
import 'package:lastanswer/ui_chat/actor_brain.dart';
import 'package:lastanswer/ui_chat/brain_health_dot.dart';
import 'package:lastanswer/ui_models/agent_config/agent_config_persistence.dart';

/// Saved ACP servers currently loaded, or none when the store is absent.
List<AcpServerFact> acpServersIn(final BuildContext context) {
  try {
    final store = context.read<AgentConfigStore>();
    return <AcpServerFact>[
      for (final entry in store.config.agentServers.entries)
        if (entry.value.command.trim().isNotEmpty)
          (
            id: entry.key,
            label: entry.value.displayName ?? entry.key,
            command: entry.value.command,
            arguments: entry.value.args,
            environment: entry.value.env,
          ),
    ];
  } on Object {
    return const <AcpServerFact>[];
  }
}

/// Runnable ACP models right now: detected installs, then saved servers.
List<({String id, String label})> liveAcpModels(final BuildContext context) =>
    <({String id, String label})>[
      for (final model in acpModelCatalog(
        detected: AcpBridgeRegistry.detectedAgents.value,
        servers: acpServersIn(context),
      ))
        (id: model.id, label: model.label),
    ];

/// Two dropdowns. [modelKeyName] stays `actor.edit.brain` / `firstrun.brain`
/// so the model step keeps the existing contract key.
final class BrainProviderPicker extends StatelessWidget {
  const BrainProviderPicker({
    required this.options,
    required this.brainRef,
    required this.onChanged,
    this.castProviders = const {},
    this.providerKeyName = 'actor.edit.provider',
    this.modelKeyName = 'actor.edit.brain',
    this.enabled = true,
    super.key,
  });

  final List<({String ref, String label})> options;
  final String? brainRef;
  final ValueChanged<String>? onChanged;
  final Map<String, String> castProviders;
  final String providerKeyName;
  final String modelKeyName;
  final bool enabled;

  @override
  Widget build(final BuildContext context) {
    final live = <Listenable>[
      AcpBridgeRegistry.detectedAgents,
      ?_storeOrNull(context),
    ];
    return ListenableBuilder(
      listenable: Listenable.merge(live),
      builder: (final context, final _) {
        final rows = <({String ref, String label})>[
          for (final option in options)
            if (parseAcpBrainRef(option.ref) == null) option,
          for (final model in liveAcpModels(context))
            (ref: acpBrainRef(model.id), label: model.label),
          if (brainRef != null &&
              brainRef!.isNotEmpty &&
              !options.any((final option) => option.ref == brainRef) &&
              !liveAcpModels(context).any(
                (final model) => acpBrainRef(model.id) == brainRef,
              ))
            (ref: brainRef!, label: brainRef!),
        ];
        final providers = groupBrainOptions(
          rows,
          castProviderOf: castProviders,
        );
        if (providers.isEmpty) return const SizedBox.shrink();
        final selected = _selection(providers, brainRef);
        final provider = selected.provider;
        final models = provider.models;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LaSelect<String>(
              key: ValueKey(providerKeyName),
              value: provider.id,
              expand: true,
              placeholder: context.l10n.modelsProviders,
              items: [
                for (final row in providers)
                  LaSelectItem(value: row.id, label: row.label),
              ],
              onChanged: !enabled
                  ? null
                  : (final id) {
                      if (id == null || onChanged == null) return;
                      final next = providers
                          .where((final row) => row.id == id)
                          .firstOrNull;
                      final model = next?.models.firstOrNull;
                      if (model != null) onChanged!(model.ref);
                    },
            ),
            const SizedBox(height: 8),
            LaSelect<String>(
              key: ValueKey(modelKeyName),
              value: models.any((final row) => row.ref == selected.model.ref)
                  ? selected.model.ref
                  : models.first.ref,
              expand: true,
              placeholder: context.l10n.actorsBrainLabel,
              items: [
                for (final row in models)
                  LaSelectItem(
                    value: row.ref,
                    label: row.label,
                    icon: BrainHealthDot(brainRef: row.ref),
                  ),
              ],
              onChanged: !enabled
                  ? null
                  : (final ref) {
                      if (ref != null) onChanged?.call(ref);
                    },
            ),
          ],
        );
      },
    );
  }
}

AgentConfigStore? _storeOrNull(final BuildContext context) {
  try {
    return context.read<AgentConfigStore>();
  } on Object {
    return null;
  }
}

({BrainProvider provider, ({String ref, String label}) model}) _selection(
  final List<BrainProvider> providers,
  final String? brainRef,
) {
  final base = brainRef?.trim() ?? '';
  for (final provider in providers) {
    for (final model in provider.models) {
      if (model.ref == base) return (provider: provider, model: model);
    }
  }
  final provider = providers.first;
  return (provider: provider, model: provider.models.first);
}
