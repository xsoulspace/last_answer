import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/supervisor_service.dart';
import 'package:lastanswer/settings/features/supervisor_view.dart';

/// The device's declared automations and what this device knows about
/// them (oka ADR-0041 §6): one row per component from the on-device
/// plans plus the machine registry's records — read-only, presence
/// grade. Declaring lives in plans; running is the converge/resident
/// rung's business, never this pane's.
class SupervisorPanel extends StatefulWidget {
  const SupervisorPanel({super.key});

  @override
  State<SupervisorPanel> createState() => _SupervisorPanelState();
}

class _SupervisorPanelState extends State<SupervisorPanel> {
  SupervisorService? _service;
  Future<SupervisorView>? _view;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final service = await SupervisorService.forDevice();
    if (!mounted) return;
    setState(() {
      _service = service;
      _view = service.load();
    });
  }

  Future<void> _refresh() async {
    final service = _service;
    if (service == null) return;
    setState(() => _view = service.load());
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.supervisorSectionTitle,
                style: context.textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: l10n.supervisorSectionRefresh,
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        FutureBuilder<SupervisorView>(
          future: _view,
          builder: (final context, final snapshot) {
            final view = snapshot.data;
            if (view == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!view.supported) {
              return Text(
                l10n.supervisorSectionUnsupported,
                style: context.textTheme.bodySmall,
              );
            }
            if (view.automations.isEmpty && view.corruptRecords.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l10n.supervisorSectionEmpty,
                  style: context.textTheme.bodySmall,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final automation in view.automations)
                  _AutomationRow(automation: automation),
                for (final corrupt in view.corruptRecords)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      corrupt,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AutomationRow extends StatelessWidget {
  const _AutomationRow({required this.automation});

  final SupervisorAutomationView automation;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final color = automation.drifted
        ? context.theme.colorScheme.error
        : automation.present
        ? Colors.green
        : context.theme.colorScheme.outline;
    final meta = <String>[
      automation.shape,
      automation.trigger,
      if (automation.drifted) l10n.supervisorSectionDrifted,
      if (automation.lastRun != null) 'last run: ${automation.lastRun}',
    ].join(' · ');
    final badge = automation.restartCount == null
        ? 'e${automation.epoch}'
        : 'e${automation.epoch} · r${automation.restartCount}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(automation.id, style: context.textTheme.bodyMedium),
                Text(
                  meta,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (automation.epoch != null)
            Text(
              badge,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }
}
