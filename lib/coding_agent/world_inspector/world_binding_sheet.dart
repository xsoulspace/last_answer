// ignore_for_file: lines_longer_than_80_chars

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:lastanswer/coding_agent/world_inspector/external_worlds_stub.dart'
    if (dart.library.io)
        'package:lastanswer/coding_agent/world_inspector/external_worlds_io.dart'
    as external_worlds;
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';

/// The result of the world-binding sheet: [picked] false = dismissed
/// (no change); [binding] null = the EMBEDDED world (the default path).
final class WorldBindingChoice {
  const WorldBindingChoice._({required this.picked, this.binding});
  const WorldBindingChoice.dismissed() : this._(picked: false);
  const WorldBindingChoice.embedded() : this._(picked: true);
  const WorldBindingChoice.world(this.binding) : picked = true;

  final WorldBindingModel? binding;
  final bool picked;
}

/// The world picker: the ONE connect surface for humans (creation and
/// the inspector's connect affordance share it). Discovery is
/// live-as-of-open — this device's daemon worlds plus the paired
/// registry — and the manual-endpoint route is always present: the OSS
/// app connects to whatever the USER chooses; nothing is hardcoded, and
/// an empty roster says so honestly.
Future<WorldBindingChoice> showWorldBindingSheet(
  final BuildContext context, {
  final WorldBindingModel? current,
}) async {
  final worlds = await external_worlds.discoverWorlds();
  if (!context.mounted) return const WorldBindingChoice.dismissed();
  final choice = await showAdaptiveDialog<WorldBindingChoice>(
    context: context,
    builder: (final context) => _WorldBindingSheet(worlds: worlds, current: current),
  );
  return choice ?? const WorldBindingChoice.dismissed();
}

class _WorldBindingSheet extends StatelessWidget {
  const _WorldBindingSheet({required this.worlds, this.current});

  final List<DiscoveredWorld> worlds;
  final WorldBindingModel? current;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AlertDialog.adaptive(
      title: Text(l10n.worldBindingSheetTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The default path FIRST: the embedded world this app runs.
            _row(
              context: context,
              title: l10n.worldBindingEmbedded,
              subtitle: l10n.worldBindingEmbeddedSubtitle,
              selected: current == null,
              icon: Icons.home_work_outlined,
              onPick: () => Navigator.of(context)
                  .pop(const WorldBindingChoice.embedded()),
            ),
            const Divider(height: 12),
            if (worlds.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Text(
                  l10n.worldBindingNoWorlds,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: worlds.length,
                  itemBuilder: (final context, final index) {
                    final world = worlds[index];
                    final selected =
                        current?.worldId == world.worldId &&
                        current?.endpoint == world.endpoint;
                    return _row(
                      context: context,
                      title: world.displayName.isEmpty
                          ? world.worldId
                          : world.displayName,
                      subtitle: '${world.endpoint}'
                          ' · ${world.source}'
                          '${world.hasSeat ? ' · ${l10n.worldBindingSeat}' : ''}'
                          '${world.token.isEmpty ? ' · ${l10n.worldBindingReadOnly}' : ''}',
                      selected: selected,
                      icon: world.source == 'paired'
                          ? Icons.devices_outlined
                          : Icons.dns_outlined,
                      onPick: () => Navigator.of(context)
                          .pop(WorldBindingChoice.world(world.toBinding())),
                    );
                  },
                ),
              ),
            const Divider(height: 12),
            _row(
              context: context,
              title: l10n.worldBindingManual,
              subtitle: l10n.worldBindingManualHint,
              icon: Icons.add_link_outlined,
              onPick: () => _addManual(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const WorldBindingChoice.dismissed()),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }

  Widget _row({
    required final BuildContext context,
    required final String title,
    required final String subtitle,
    required final IconData icon,
    required final VoidCallback onPick,
    final bool selected = false,
  }) => ListTile(
    key: Key('world_binding.$title'),
    dense: true,
    leading: Icon(icon, size: 20),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: selected ? const Icon(Icons.check, size: 16) : null,
    onTap: onPick,
  );

  Future<void> _addManual(final BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: 'http://127.0.0.1:');
    String? error;
    final binding = await showAdaptiveDialog<WorldBindingModel>(
      context: context,
      builder: (final context) => StatefulBuilder(
        builder: (final context, final setState) => AlertDialog.adaptive(
          title: Text(l10n.worldBindingManual),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('world_binding.endpoint_field'),
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.worldBindingEndpointLabel,
                  hintText: l10n.worldBindingManualHint,
                  errorText: error,
                ),
                onSubmitted: (final value) {
                  final parsed = parseManualBinding(value);
                  if (parsed == null) {
                    setState(() => error = l10n.worldBindingInvalidEndpoint);
                    return;
                  }
                  Navigator.of(context).pop(parsed);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
              ),
            ),
            TextButton(
              key: const Key('world_binding.manual_connect'),
              onPressed: () {
                final parsed = parseManualBinding(controller.text);
                if (parsed == null) {
                  setState(() => error = l10n.worldBindingInvalidEndpoint);
                  return;
                }
                Navigator.of(context).pop(parsed);
              },
              child: Text(
                MaterialLocalizations.of(context).okButtonLabel,
              ),
            ),
          ],
        ),
      ),
    );
    if (binding != null && context.mounted) {
      Navigator.of(context).pop(WorldBindingChoice.world(binding));
    }
  }
}
